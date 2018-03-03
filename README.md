# Threads
2016 BYU CS 224 Lab 8

### Description
"Write 4 functions (threads) to turn each of the lights on the board on and off. Then pass these threads to a pthread_create function that will create a process control block that has room to save the registers for each thread. You should then use the watchdog timer to context switch between each of these threads."

### Learn
- Context switch between running processes on a single CPU.
- Understand the basics of scheduling.
- Write systems level programs from scratch.


### Specs
- 1 point	Your Threads lab contains both C and MSP430 assembler files that link together and contain header comments that include your name and a declaration that the completed assignment is your own work.
- 1 points	Each of your thread functions works correctly when called from main().
- 1 points	Your int pthread_create(void *(*start_routine) (void *)) function creates a process control block for each thread with the correct function address.
- 1 points	Your assembly language interrupt handler turns the small green lighton and off every one second while your program is running.
- 4 points	Your assembly language interrupt handler can successfully switch to one of the threads started by pthread_create even if it cant switch back or round robin schedule through all of the threads.
- 2 points	Your assembly language interrupt handler correctly saves away registers for one thread and restores registers for another thread each time it is activated. Your main() code should start one thread, wait for 5 seconds, start the next thread until all of them are running. You should notice that the first LED flashes more slowly when the other threads are started, but they should all flash at about the same frequency in the end.


https://students.cs.byu.edu/~clement/cs224/labs/Lthreads/threads.php
