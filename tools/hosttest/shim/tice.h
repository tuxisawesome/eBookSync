#ifndef TICE_H
#define TICE_H

#include "shim.h"

#define os_ClrHome() shim_os_clr_home()
void shim_os_clr_home(void);
void os_SetCursorPos(uint8_t row, uint8_t col);
uint24_t os_PutStrFull(const char *string);

#endif
