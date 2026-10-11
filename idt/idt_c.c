#include <stddef.h>
#include <stdint.h>


typedef uint8_t byte;
typedef uint16_t word;
typedef uint32_t dword;


typedef struct __attribute__((packed)) {
	word size;
	dword offset;
}IDT_DES;

typedef struct __attribute__((packed)) {
	word offset1;
	word seg_sel;			// code segment (index to gdt)
	byte zero;
	byte type_attr;			// gate type [4] = 0xe -> 32 bit interupt gate, 0 [1], DPL [2] = 0 -> priviliage level, P [1]=1
	word offset2;
}IDT_GATE;


IDT_GATE gates[256];


void set_gate(int gate_number ,dword offset){
	word offset1 = offset & 0xffff;
	word offset2 = offset >> 16;
	gates[gate_number].offset1=offset1;
	gates[gate_number].offset2=offset2;
	gates[gate_number].zero=0;
	gates[gate_number].type_attr=0b10001110;
	gates[gate_number].seg_sel = 0x8;
}

extern void default_isr(void);		// from idt.asm

void idt_init(void){
	IDT_DES idt_des;
	for(int i=0; i<256; i++)
		set_gate(i,(dword)default_isr);
	idt_des.size = sizeof(gates) - 1;
	idt_des.offset = (dword)gates;
	__asm__ __volatile__("lidt %0" : : "m"(idt_des));
}


