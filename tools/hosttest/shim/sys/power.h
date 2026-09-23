/* CPU speed and the automatic power-down, which the lock screen uses to turn
 * the calculator off through the OS rather than imitating it. */
#ifndef SHIM_SYS_POWER_H
#define SHIM_SYS_POWER_H
#include <stdint.h>

void boot_Set6MHzMode(void);
void boot_Set48MHzMode(void);
void os_EnableAPD(void);

/* 0 (nearly flat) to 4 (full), and whether it is on charge. Settable, so the
 * book list's battery gauge can be checked at every level. */
uint8_t boot_GetBatteryStatus(void);
uint8_t boot_BatteryCharging(void);
extern uint8_t shim_battery;
extern uint8_t shim_charging;
void os_DisableAPD(void);

extern uint8_t shim_apd_sub_timer;
extern uint8_t shim_apd_timer;
#define os_ApdSubTimer shim_apd_sub_timer
#define os_ApdTimer    shim_apd_timer
#endif
