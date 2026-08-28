/*
 * calc/src/chat.c, driven from a script.
 *
 * The browser packs the records and this parses them with the real reader code,
 * and vice versa -- the same two-implementations discipline the library index
 * and the .csx container are held to. A chat format that only one side can read
 * would show up as an empty screen on hardware and nowhere else.
 *
 *   chat_probe <dir> <command>...
 *
 *     table <file>          CHAT_ROSTER_PUT with the file's bytes
 *     append <id> <file>    CHAT_IN_PUT for one conversation
 *     send <id> <text>      type a message here
 *     drop <n>              CHAT_OUT_ACK
 *     list                  print the conversations
 *     messages <index>      print one conversation's messages
 *     outbox                print the queue
 *     save                  write every variable to <dir> as <NAME>.bin
 */

#include "chat.h"

#include "fileioc.h"
#include "library.h"
#include "shim.h"

#include <dirent.h>
#include <stdlib.h>
#include <string.h>

uint8_t *read_appvar(const char *path, char *name, size_t *size);

static uint8_t *slurp(const char *path, size_t *size);

/*
 * Load the calculator's variables from the directory.
 *
 * `.8xv` files are wrapped the way TI Connect writes them; `.bin` files are the
 * raw payload, which is what `save` below produces. Loading both is what lets a
 * test run the probe several times over and see the state the last run left --
 * which is the only way to check that a read position survives the next sync.
 */
static void load_all(const char *directory) {
    for (int pass = 0; pass < 2; pass++) {
        const char *want = pass == 0 ? ".8xv" : ".bin";

        DIR *dir = opendir(directory);
        for (struct dirent *entry; dir && (entry = readdir(dir)); ) {
            const char *dot = strrchr(entry->d_name, '.');
            if (!dot || strcmp(dot, want) != 0)
                continue;

            char path[4096];
            snprintf(path, sizeof path, "%s/%s", directory, entry->d_name);

            char name[9];
            size_t size;
            uint8_t *data;

            if (pass == 0) {
                data = read_appvar(path, name, &size);
            } else {
                size_t length = (size_t)(dot - entry->d_name);
                if (length > 8)
                    continue;
                memcpy(name, entry->d_name, length);
                name[length] = '\0';
                data = slurp(path, &size);
                /* A saved copy is newer than whatever the .8xv held. */
                ti_Delete(name);
            }

            if (data) {
                shim_add_var(name, data, size);
                free(data);
            }
        }
        if (dir)
            closedir(dir);
    }
}

static void save_all(const char *directory) {
    const char *name;
    const uint8_t *data;
    size_t size;
    for (int i = 0; shim_var_at(i, &name, &data, &size); i++) {
        char path[4096];
        snprintf(path, sizeof path, "%s/%s.bin", directory, name);
        FILE *file = fopen(path, "wb");
        if (!file)
            continue;
        fwrite(data, 1, size, file);
        fclose(file);
    }
}

static uint8_t *slurp(const char *path, size_t *size) {
    FILE *file = fopen(path, "rb");
    if (!file)
        return NULL;

    fseek(file, 0, SEEK_END);
    *size = (size_t)ftell(file);
    fseek(file, 0, SEEK_SET);

    uint8_t *data = malloc(*size ? *size : 1);
    if (fread(data, 1, *size, file) != *size) {
        free(data);
        fclose(file);
        return NULL;
    }
    fclose(file);
    return data;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: chat_probe <dir> <command>...\n");
        return 2;
    }

    load_all(argv[1]);
    lib_open();
    chat_open();

    for (int i = 2; i < argc; i++) {
        if (strcmp(argv[i], "table") == 0 && i + 1 < argc) {
            size_t size;
            uint8_t *data = slurp(argv[++i], &size);
            printf("table %d\n", data && chat_put_table(data, size) ? 1 : 0);
            free(data);

        } else if (strcmp(argv[i], "append") == 0 && i + 2 < argc) {
            uint16_t id = (uint16_t)atoi(argv[i + 1]);
            size_t size;
            uint8_t *data = slurp(argv[i + 2], &size);
            printf("append %d\n", data && chat_append(id, data, size) ? 1 : 0);
            free(data);
            i += 2;

        } else if (strcmp(argv[i], "send") == 0 && i + 2 < argc) {
            printf("send %d\n",
                   chat_send((uint16_t)atoi(argv[i + 1]), argv[i + 2]) ? 1 : 0);
            i += 2;

        } else if (strcmp(argv[i], "drop") == 0 && i + 1 < argc) {
            printf("drop %d\n", chat_outbox_drop((uint16_t)atoi(argv[++i])) ? 1 : 0);

        } else if (strcmp(argv[i], "list") == 0) {
            printf("conversations %u\n", chat_conversation_count());
            for (uint8_t c = 0; c < chat_conversation_count(); c++) {
                chat_conversation_t conversation;
                chat_get_conversation(c, &conversation);
                printf("conversation %u %lu %u %s\n", conversation.id,
                       (unsigned long)conversation.last_server_id,
                       conversation.bytes, conversation.name);
            }

        } else if (strcmp(argv[i], "messages") == 0 && i + 1 < argc) {
            uint8_t index = (uint8_t)atoi(argv[++i]);
            uint16_t count = chat_message_count(index);
            printf("messages %u\n", count);
            for (uint16_t m = 0; m < count; m++) {
                chat_message_t message;
                if (!chat_get_message(index, m, &message)) {
                    printf("message-error %u\n", m);
                    break;
                }
                printf("message %lu %lu %u %s|%s\n",
                       (unsigned long)message.server_id,
                       (unsigned long)message.sent_at,
                       message.flags, message.sender, message.body);
            }

        } else if (strcmp(argv[i], "outbox") == 0) {
            printf("outbox %u %u\n", chat_outbox_count(), chat_outbox_bytes());
            for (uint16_t o = 0; o < chat_outbox_count(); o++) {
                uint8_t record[512];
                uint16_t length = 0;
                if (!chat_outbox_get(o, record, &length)) {
                    printf("outbox-error %u\n", o);
                    break;
                }
                printf("queued %u", length);
                for (uint16_t b = 0; b < length; b++)
                    printf(" %02x", record[b]);
                printf("\n");
            }

        } else if (strcmp(argv[i], "save") == 0) {
            save_all(argv[1]);

        } else {
            fprintf(stderr, "unknown command \"%s\"\n", argv[i]);
            return 2;
        }
    }

    return 0;
}
