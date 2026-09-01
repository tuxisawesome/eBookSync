/*
 * The calculator's own clock, which the lock screen shows.
 *
 * Fixed here rather than taken from the host, so a test that checks what the
 * bar says checks the same thing every time it runs.
 */
#ifndef SHIM_SYS_RTC_H
#define SHIM_SYS_RTC_H
#include <stdint.h>
void boot_GetDate(uint8_t *day, uint8_t *month, uint16_t *year);
void boot_GetTime(uint8_t *seconds, uint8_t *minutes, uint8_t *hours);
void shim_set_clock(uint8_t day, uint8_t month, uint16_t year,
                    uint8_t hours, uint8_t minutes);
#endif
