#ifndef KEYPADC_H
#define KEYPADC_H
#include <stdint.h>
typedef uint16_t kb_lkey_t;
extern uint16_t shim_kb_data[8];
#define kb_Data shim_kb_data
void kb_Scan(void);

extern uint8_t shim_kb_config;
#define kb_Config shim_kb_config
#define kb_SetMode(mode) (kb_Config = (uint8_t)((kb_Config & ~3) | (mode)))
typedef enum {
    MODE_0_IDLE = 0,
    MODE_1_INDISCRIMINATE,
    MODE_2_SINGLE,
    MODE_3_CONTINUOUS
} kb_scan_mode_t;
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
#define kb_KeyYequ  ((kb_lkey_t)(1 << 8 | 1<<4))
#define kb_KeyAlpha ((kb_lkey_t)(2 << 8 | 1<<7))

/* The rest of the keypad, so keyin.c can be driven from a test script. Values
 * are keypadc's own; a wrong one here would be a test that types something
 * other than what a person pressing that key would get. */
#define kb_KeySto     ((kb_lkey_t)(2 << 8 | 1<<1))
#define kb_KeyLn      ((kb_lkey_t)(2 << 8 | 1<<2))
#define kb_KeyLog     ((kb_lkey_t)(2 << 8 | 1<<3))
#define kb_KeySquare  ((kb_lkey_t)(2 << 8 | 1<<4))
#define kb_KeyRecip   ((kb_lkey_t)(2 << 8 | 1<<5))
#define kb_KeyMath    ((kb_lkey_t)(2 << 8 | 1<<6))
#define kb_Key0       ((kb_lkey_t)(3 << 8 | 1<<0))
#define kb_Key1       ((kb_lkey_t)(3 << 8 | 1<<1))
#define kb_Key4       ((kb_lkey_t)(3 << 8 | 1<<2))
#define kb_Key7       ((kb_lkey_t)(3 << 8 | 1<<3))
#define kb_KeyComma   ((kb_lkey_t)(3 << 8 | 1<<4))
#define kb_KeySin     ((kb_lkey_t)(3 << 8 | 1<<5))
#define kb_KeyApps    ((kb_lkey_t)(3 << 8 | 1<<6))
#define kb_KeyDecPnt  ((kb_lkey_t)(4 << 8 | 1<<0))
#define kb_Key2       ((kb_lkey_t)(4 << 8 | 1<<1))
#define kb_Key5       ((kb_lkey_t)(4 << 8 | 1<<2))
#define kb_Key8       ((kb_lkey_t)(4 << 8 | 1<<3))
#define kb_KeyLParen  ((kb_lkey_t)(4 << 8 | 1<<4))
#define kb_KeyCos     ((kb_lkey_t)(4 << 8 | 1<<5))
#define kb_KeyPrgm    ((kb_lkey_t)(4 << 8 | 1<<6))
#define kb_KeyChs     ((kb_lkey_t)(5 << 8 | 1<<0))
#define kb_Key3       ((kb_lkey_t)(5 << 8 | 1<<1))
#define kb_Key6       ((kb_lkey_t)(5 << 8 | 1<<2))
#define kb_Key9       ((kb_lkey_t)(5 << 8 | 1<<3))
#define kb_KeyRParen  ((kb_lkey_t)(5 << 8 | 1<<4))
#define kb_KeyTan     ((kb_lkey_t)(5 << 8 | 1<<5))
#define kb_KeyMul     ((kb_lkey_t)(6 << 8 | 1<<3))
#define kb_KeyDiv     ((kb_lkey_t)(6 << 8 | 1<<4))
#define kb_KeyPower   ((kb_lkey_t)(6 << 8 | 1<<5))
#define kb_IsDown(lkey) (kb_Data[(lkey) >> 8] & (lkey))
#endif
