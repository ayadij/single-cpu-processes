;    threadsISR.asm    08/07/2015
;*******************************************************************************
;  STATE        Task Control Block        Stacks (malloc'd)
;                          ______                                       T0 Stack
;  Running tcbs[0].thread | xxxx-+------------------------------------->|      |
;                 .stack  | xxxx-+-------------------------------       |      |
;                 .block  | 0000 |                               \      |      |
;                 .retval |_0000_|                       T1 Stack \     |      |
;  Ready   tcbs[1].thread | xxxx-+---------------------->|      |  \    |      |
;                 .stack  | xxxx-+------------------     |      |   \   |      |
;                 .block  | 0000 |                  \    |      |    -->|(exit)|
;                 .retval |_0000_|        T2 Stack   --->|r4-r15|       |------|
;  Blocked tcbs[2].thread | xxxx-+------->|      |       |  SR  |
;                 .stack  | xxxx-+---     |      |       |  PC  |
;                 .block  |(sem) |   \    |      |       |(exit)|
;                 .retval |_0000_|    --->|r4-r15|       |------|
;  Free    tcbs[3].thread | 0000 |        |  SR  |
;                 .stack  | ---- |        |  PC  |

;                 .block  | ---- |        |(exit)|
;                 .retval |_----_|        |------|
;
;*******************************************************************************

            .cdecls C,"msp430.h"            ; MSP430
            .cdecls C,"pthreads.h"          ; threads header

            .def    TA_isr
            .ref    ctid
            .ref    tcbs
            .bss    count,0

tcb_thread  .equ    (tcbs + 0)	;//the size of each thread tcbs+n and multiples of 8 (explained in step 3)
tcb_stack   .equ    (tcbs + 2)	;//stack information we want to save this into the tcb_block
tcb_block   .equ    (tcbs + 4)

; Code Section ------------------------------------------------------------

            .text                           ; beginning of executable code
; Timer A ISR -------------------------------------------------------------
TA_isr:     bic.w   #TAIFG|TAIE,&TACTL      ; acknowledge & disable TA interrupt
;
; >>>>>> 1. Save current context on stack
			push 	r15						;//saving registers r4-15 on the stack		;//not registers r0-3
			push 	r14
			push 	r13
			push 	r12
			push 	r11
			push 	r10
			push 	r9
			push 	r8
			push 	r7
			push 	r6
			push 	r5
			push 	r4

; >>>>>> 2. Save SP in task control block


											;				basically what is happening here:
											;				for(int i = 0; i < MAX_THREADS; i++)
											;				{
											;					is it alive?
											;					is it blocked?
											;					if (yes || no)
											;						then use that thread
											;					else
											;						check next thread
											;				}
											;				if all blocked
											;					go to sleep
											;					restore everything
											;
											;				if i just woke up
											;					jump back to the for loop and check everthing again



			mov.w	&ctid,r15	;//we are on thread ctid (current thread id) we want to save the stack pointer to the ctid
			add.w	r15,r15					;//make sure the thread ID is what you want
			add.w	r15,r15
			add.w	r15,r15
			mov.w	SP,tcb_stack(r15)

			clr.w	&count

; >>>>>> 3. Find next non-blocked thread tcb			;//check if it exists. if it does, restore and continue


find_unbk:	cmp.w	#MAX_THREADS,&count		;have we checked all 4 threads? ;4 potential threads ;&count is a global variable ;count is 0 the first time
			jge		wait_unbk				;yes, go to sleep, enable interrupts and wait for the thread to unblock
			inc.w	&ctid					;get the next thread
			cmp.w	#MAX_THREADS,&ctid		;is the current thread index over the max threads? ;cannot be over 4
			jl		cnt_find				;no, continue
			clr.w	&ctid					;yes, reset the thread index

cnt_find:	mov.w	&ctid,r4				;move the ctid to r4
			add.w	r4,r4
			add.w	r4,r4
			add.w	r4,r4
			cmp.w	#0,tcb_thread(r4)
			jeq		inc_count
			mov.w	tcb_block(r4),r5		;move contents of block to r5
			cmp.w 	#0,r5					;is current thread blocked?
			jeq		found_unbk				;no, we can switch to this one

inc_count:	inc.w	&count					;yes can't switch to it.. increment thread count
			jmp		find_unbk				;check to see if next thread is available


; >>>>>> 4. If all threads blocked, enable interrupts in LPM0

wait_unbk:	bis.w	#(LPM0|GIE),SR			;no unblocked threats at the moment, so enable interrupts
			clr.w	&count					;start over to find available thread ;make sure you reset this
			jmp		find_unbk


; >>>>>> 5. Set new SP
found_unbk:	mov.w 	&ctid,r15
			add.w	r15, r15
			add.w	r15, r15
			add.w	r15, r15
			mov.w	tcb_stack(r15),SP


; >>>>>> 6. Load context from stack
			pop 	r4						;//takes the values and stores it in the destination ;//pops the top of the stack
			pop 	r5
			pop 	r6
			pop		r7
			pop		r8
			pop		r9
			pop		r10
			pop		r11
			pop		r12
			pop		r13
			pop		r14
			pop		r15

            bis.w    #TAIE,&TACTL           ; enable TA interrupts
            reti


; Interrupt Vector --------------------------------------------------------
            .sect   ".int08"                ; timer A section
            .word   TA_isr                  ; timer A isr
            .end
