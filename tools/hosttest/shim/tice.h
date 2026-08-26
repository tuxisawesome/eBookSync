#ifndef TICE_H
#define TICE_H

#include "shim.h"

#define os_ClrHome() shim_os_clr_home()
void shim_os_clr_home(void);
void os_SetCursorPos(uint8_t row, uint8_t col);
uint24_t os_PutStrFull(const char *string);


/* One call, and the answer lands in os_TempFreeArc. */
void os_ArcChk(void);
extern uint24_t shim_temp_free_arc;
#define os_TempFreeArc shim_temp_free_arc

#endif
