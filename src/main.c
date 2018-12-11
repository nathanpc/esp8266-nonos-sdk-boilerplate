/**
 * main.c
 * ESP8266 main source code.
 *
 * @author Nathan Campos <nathan@innoveworkshop.com>
 */

#include <c_types.h>
#include <osapi.h>
#include <os_type.h>

LOCAL os_timer_t some_timer;

LOCAL void ICACHE_FLASH_ATTR some_timerfunc(void *arg) {
	os_printf("Hello\n\r");
	os_printf("SDK version:%s\n", system_get_sdk_version());
	os_printf("Module Test\nChip_id: %lu\n", system_get_chip_id());
	os_printf("Free RAM: %d\r\n", system_get_free_heap_size());
}

void ICACHE_FLASH_ATTR user_init() {
	// Set the baud rate to match the boot debug.
	uart_div_modify(0, UART_CLK_FREQ / 9600);
	
	// Setup a timer for our test.
	os_timer_setfn(&some_timer, (os_timer_func_t *)some_timerfunc, (void *)0);
	os_timer_arm(&some_timer, 1000, 1);
}

