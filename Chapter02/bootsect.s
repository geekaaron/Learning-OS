
# Program Name - bootsect
# Author - Aaron
# Date - 2018/12/4

# Updated:
#	2018/12/6 - Load demo to 0x9000:0000 and jump to it

# Booting from 16-bit real mode because of backward compatible
.code16

# text section - contains pure binary code of the program
.section .text

# 16-bit real mode addressing mode:
# 	segment:offset --> segment<<4 + offset
#	e.g. 0x07c0:0000 --> 0x07c0<<4 + 0x0000 = 0x7c00

.equ BOOTSEG,	0x07c0	# The segment of our boot code loaded by BIOS
.equ MSGLEN,	20	# Length of messege at msg
.equ DEMOSEG,	0x9000	# The segment of demo
.equ DEMOLEN,	1	# The number of sectors to read of demo

.global _bootsect

_bootsect:

	# Get cursor position
	mov $0x03, %ah	# int=0x10/ah=0x03 -> Read cursor position
	mov $0, %bh	# bh=0 -> Video page 0
	int $0x10	# Get the cursor position and store it to dx (dh=row, dl=column)

	# Print messege at msg
	mov $BOOTSEG, %ax	# Note, we can not directly change segment register
	mov %ax, %es		# Set es to the segment of our boot code
	mov $msg, %bp		# bp -> msg, actually es:bp -> msg
	mov $0x1301, %ax	# int=0x10/ah=0x13 -> Write string; al=01 -> cursor moved
	mov $0x000a, %bx	# bh=0 -> Video page 0; bl=0x0a -> green font color
	mov $MSGLEN, %cx	# cx=20 -> Length of messege at msg
	int $0x10		# Write string on screen

	# Read disk
load_demo:
	mov $DEMOSEG, %ax	# Use ax register to change es segment register
	mov %ax, %es		# Set es to the segment of demo
	mov $0, %bx		# bx=0 -> offset=0; es:bx -> 0x9000:0000 = 0x90000
	mov $0x0200+DEMOLEN, %ax# int=0x13/ah=0x02 -> Read disk sectors; al=1 -> Read 1 sector
	mov $0x0002, %cx	# ch=0 -> Cylinder 0; cl=2 -> sector number 2
	mov $0x0000, %dx	# dh=0 -> head number 0; dl=0 -> drive number 0 (floppy disk)
	int $0x13		# Read 1 sector from 0-0-2 (CHS) in floppy to 0x90000

	jc reset_disk		# Read failed if cf=1

	cmp $DEMOLEN, %al	# if al (number of sectors actually read) == 1 (we need to read)
	je load_demo_done	# demo load successful

reset_disk:
	mov $0, %ah	# int=0x13/ah=0 -> Reset disk system
	mov $0, %dl	# dl=0 -> drive number 0 (floppy disk)
	int $0x10	# Reset disk stat
	jmp load_demo	# Load demo again

	# Long jump to demo (0x9000:0000)
load_demo_done:
	ljmp $DEMOSEG, $0

msg:
	.ascii "\r\nReading disk ...\r\n"

# Padding to 510 bytes with 0
.= 510

# Magic number of boot sector
magic_number:
	.byte 0x55, 0xaa
