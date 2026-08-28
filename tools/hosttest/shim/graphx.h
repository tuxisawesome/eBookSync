#ifndef GRAPHX_H
#define GRAPHX_H

#include "shim.h"

#define GFX_LCD_WIDTH  320
#define GFX_LCD_HEIGHT 240

extern uint8_t shim_vbuffer[GFX_LCD_HEIGHT][GFX_LCD_WIDTH];
extern uint16_t shim_palette[256];

#define gfx_vbuffer shim_vbuffer
#define gfx_palette shim_palette

void gfx_FillScreen(uint8_t index);
uint8_t gfx_SetColor(uint8_t index);
void gfx_FillRectangle_NoClip(uint24_t x, uint24_t y, uint24_t w, uint24_t h);
void gfx_Rectangle_NoClip(uint24_t x, uint24_t y, uint24_t w, uint24_t h);
uint8_t gfx_SetTextFGColor(uint8_t color);
uint8_t gfx_SetTextBGColor(uint8_t color);
void gfx_PrintStringXY(const char *string, int x, int y);
void gfx_SwapDraw(void);
void gfx_Begin(void);
void gfx_End(void);
void gfx_SetDraw(uint8_t location);
void gfx_Wait(void);
void gfx_Blit(uint8_t src);
enum { gfx_screen = 0, gfx_buffer = 1 };
#define gfx_SetDrawBuffer() gfx_SetDraw(1)

#endif /* GRAPHX_H */
