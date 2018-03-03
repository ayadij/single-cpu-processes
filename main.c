/*
// *****************ISR TEST***********************************************************************************************
//	The best way to test your assembly (and it must be assembly) scheduler is to remove snake from the test (ie. unit test your pthreadsISR.asm scheduler).
//	Create a new CCS project with main.c.
//	Add RBX430-1.c, RBX430-1.h, RBX430lcd.c, RBX430_lcd.h, pthreads.c, and pthreads.h from the the website to your project.
//	Add YOUR pthreadsISR.asm to the project.
//	Use properties to change the heap size to 464 and stack size to 128.
//	Replace the default code in main.c with the program below.
//	Compile and verify the green, orange, and yellow LEDs turn on then off repeatedly.
//	This code will test your scheduler. DON'T PROCEED UNTIL THIS WORKS!
***************************************************************************************************************************
*/

#include <msp430.h>
#include <stdlib.h>
#include "RBX430-1.h"
#include "pthreads.h"

sem_t mySem;
void* my_thread(void* arg)
{
	while (1)
	{
		sem_wait(&mySem);
		P4OUT ^= (int)arg;
	}
}

int main(void)
{
	RBX430_init(_1MHZ);
 	WDTCTL = WDT_ADLY_250;
	IE1 |= WDTIE;
	P4DIR |= 0x0f;
	P4OUT &= 0x0f;
	pthread_init(NULL);
	semaphore_create(&mySem, 0);
	pthread_create(NULL, NULL, my_thread, (void*)0x02);
	pthread_create(NULL, NULL, my_thread, (void*)0x04);
	while (1)
	{
		_enable_interrupt();
		sem_wait(&mySem);
		P4OUT ^= 0x01;
	}
}

#pragma vector = WDT_VECTOR
__interrupt void WDT_ISR(void)
{
	sem_signal(&mySem);
	__bic_SR_register_on_exit(LPM0_bits);
}



