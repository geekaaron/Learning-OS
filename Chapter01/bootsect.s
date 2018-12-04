
# Program Name - bootsect
# Author - Aaron
# Date - 2018/12/4

# Booting from 16-bit real mode because of backward compatible
.code16

# text section - contains pure binary code of the program
.section .text

# 16-bit real mode addressing mode:
# 	segment:offset --> segment<<4 + offset
#	e.g. 0x07c0:0000 --> 0x07c0<<4 + 0x0000 = 0x7c00

# The segment of our boot code loaded by BIOS
# Length of messege at msg
.equ BOOTSEG,	0x07c0
.equ MSGLEN,	34

.global _bootsect

_bootsect:

	mov $0x03, %ah	# int=0x10/ah=0x03 -> Read cursor position
	mov $0x00, %bh	# bh=0 -> Video page 0
	int $0x10	# Get the cursor position and store it into dx (dh=row, dl=column)

	mov $BOOTSEG, %ax	# Note, we can not directly change segment register
	mov %ax, %es		# Set es to the segment of our boot code
	mov $msg, %bp		# bp -> msg, actually es:bp -> msg
	mov $0x1301, %ax	# int=0x10/ah=0x13 -> Write string; al=01 -> cursor moved
	mov $0x000a, %bx	# bh=0 -> Video page 0; bl=0x0a -> green font color
	mov $MSGLEN, %cx	# cx=34 -> Length of messege at msg
	int $0x10		# Write string on screen

hold:
	jmp hold	# Implement endless loop

msg:
	.ascii "Welcome to the 16-bit real mode!"
	.byte 0x0d, 0x0a	# New line

# Padding to 510 bytes with 0
.= 510

# Magic number of boot sector
magic_number:
	.byte 0x55, 0xaa
