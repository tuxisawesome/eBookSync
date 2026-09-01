/* CPU speed and the automatic power-down, which the lock screen uses to turn
 * the calculator off through the OS rather than imitating it. */
#ifndef SHIM_SYS_POWER_H
#define SHIM_SYS_POWER_H
#include <stdint.h>

void boot_Set6MHzMode(void);
void boot_Set48MHzMode(void);
void os_EnableAPD(void);
void os_DisableAPD(void);

extern uint8_t shim_apd_sub_timer;
extern uint8_t shim_apd_timer;
#define os_ApdSubTimer shim_apd_sub_timer
#define os_ApdTimer    shim_apd_timer
#endif
