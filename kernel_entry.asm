[BITS 32]

global _start
extern kernel_main

_start:
	call kernel_main



loop_back:
	jmp loop_back 
