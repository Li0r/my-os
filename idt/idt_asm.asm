[BITS 32]

global default_isr

extern unhandled_interupt




default_isr:				; in case of error / not planned ## for now its for all interupts for testing!
	pushad				; pushed all registers so later we can pop them sonce it was interupted call. though in this case it wont return so its pointless but still.********
	cld				; DF=0
	call unhandled_interupt
	cli				; IF (interupt flag ) = 0, that means that from now on the cpu will ignore maskable hardware interupts
	.halt:
		hlt			; make the cpu go "sleep" mode (stop the cpu) until next interupt comes
		jmp .halt		; if smth still wakes the cpu then do hlt again 
