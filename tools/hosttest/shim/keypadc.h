#ifndef KEYPADC_H
#define KEYPADC_H
#include <stdint.h>
typedef uint16_t kb_lkey_t;
extern uint16_t shim_kb_data[8];
#define kb_Data shim_kb_data
void kb_Scan(void);
#define kb_KeyUp    ((kb_lkey_t)(7 << 8 | 1<<3))
#define kb_KeyDown  ((kb_lkey_t)(7 << 8 | 1<<0))
#define kb_KeyLeft  ((kb_lkey_t)(7 << 8 | 1<<1))
#define kb_KeyRight ((kb_lkey_t)(7 << 8 | 1<<2))
#define kb_KeyEnter ((kb_lkey_t)(6 << 8 | 1<<0))
#define kb_KeyAdd   ((kb_lkey_t)(6 << 8 | 1<<1))
#define kb_KeySub   ((kb_lkey_t)(6 << 8 | 1<<2))
#define kb_KeyClear ((kb_lkey_t)(6 << 8 | 1<<6))
#define kb_Key2nd   ((kb_lkey_t)(1 << 8 | 1<<5))
#define kb_KeyMode  ((kb_lkey_t)(1 << 8 | 1<<6))
#define kb_KeyDel   ((kb_lkey_t)(1 << 8 | 1<<7))
#define kb_IsDown(lkey) (kb_Data[(lkey) >> 8] & (lkey))
#endif
