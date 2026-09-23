/* The backlight, which the lock screen turns off, and the LCD's memory, which
 * the sync screen draws into in the OS's 16bpp mode. */
#ifndef SHIM_SYS_LCD_H
#define SHIM_SYS_LCD_H
#include <stdint.h>
extern uint8_t shim_backlight;
#define lcd_BacklightLevel shim_backlight

#define LCD_WIDTH  320
#define LCD_HEIGHT 240
extern uint16_t shim_lcd_ram[LCD_WIDTH * LCD_HEIGHT];
#define lcd_Ram ((void *)shim_lcd_ram)
#endif
