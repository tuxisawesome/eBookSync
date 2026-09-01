/* The OS flag bytes the reader touches: just the automatic power-down. */
#ifndef SHIM_TI_FLAGS_H
#define SHIM_TI_FLAGS_H
#include <stdint.h>

extern uint8_t shim_os_flags[256];
#define os_Flags shim_os_flags

#define OS_FLAGS_HOOKS1         0x33
#define OS_FLAGS_HOOKS1_ALT_ON  0     /* run ONSCRPT at power-on */

#define OS_FLAGS_APD            8
#define OS_FLAGS_APD_ABLE       2
#define OS_FLAGS_APD_RUNNING    3
#define OS_FLAGS_APD_WARMSTART  4

#endif
