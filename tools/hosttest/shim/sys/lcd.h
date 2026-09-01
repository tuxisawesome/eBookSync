/* Just the backlight, which the lock screen turns off. */
#ifndef SHIM_SYS_LCD_H
#define SHIM_SYS_LCD_H
#include <stdint.h>
extern uint8_t shim_backlight;
#define lcd_BacklightLevel shim_backlight
#endif
