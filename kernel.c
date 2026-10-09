#include <stdint.h>
#include <stddef.h>

typedef enum {
	BLACK,
	BLUE,
	GREEN,
	CYAN,
	RED,
	MAGENTA,
	BROWN,
	GRAY,
	DARK_GRAY,
	LIGHT_BLUE,
	LIGHT_GREEN,
	LIGHT_CYAN,
	LIGHT_RED,
	LIGHT_MAGENTA,
	YELLOW,
	WHITE
}vgaColor;

#define VGA_MEMORY 0xb8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_BYTES_PER_SLOT 2

typedef uint8_t byte;
typedef uint16_t word;
typedef uint32_t dword;

void clear_terminal(void);
//void print_str(int x, int y, char *str, int fg, int bg);
char *grid_to_addr(int x, int y);
byte create_attribute_byte(vgaColor fg, vgaColor bg);
void puts_char(int x, int y, byte chr, int fg, int bg);
void kernel_main(void);

void clear_terminal(void){
	for(int i=0;i<VGA_HEIGHT;i++){
		for(int j=0; j<VGA_WIDTH; j++){
			puts_char(j,i,' ',BLACK,BLACK);
		}
	}
}
/* still in progress
void print_str(int x, int y, char *str, int fg, int bg){
	int _x = x;
	int _y = y;
	for(int i=0; str[i]!='\0';i++){
		if(str[i]=='\n'){
			y++;	
		}
	}// still not finished
}
*/
char *grid_to_addr(int x, int y){
	int offset = (y*160)+(x*2);
	return (char *)((VGA_MEMORY)+offset);
}

byte create_attribute_byte(vgaColor fg, vgaColor bg){
	return (bg<<4) | fg;
}


void puts_char(int x, int y, byte chr, int fg, int bg){
	volatile byte *vga_mem_bufp = (volatile byte *)grid_to_addr(x,y);
	byte attribute = create_attribute_byte(fg, bg);
	vga_mem_bufp[0] = chr;
	vga_mem_bufp[1] = attribute;
}

void kernel_main(void){
	clear_terminal();
	puts_char(0,12,'H',WHITE,BLACK);	
}
