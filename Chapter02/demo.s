
# Program Name - demo
# Author - Aaron
# Date - 2018/12/6

.code16

.section .text

.equ DEMOSEG,	0x9000	# The segment of demo
.equ MSGLEN,	20	# Length of messege at msg

.global _demo

_demo:

	# Initialize ds and es with segment of demo
	mov $DEMOSEG, %ax
	mov %ax, %ds
	mov %ax, %es

	# Read cursor position
	mov $0x03, %ah
	mov $0x00, %bh
	int $0x10

	# Print messege at msg
	mov $0x1301, %ax
	mov $0x000b, %bx
	mov $MSGLEN, %cx
	mov $msg, %bp
	int $0x10

hold:
	jmp hold	# Implement endless loop

msg:
	.asciz "\r\nThere is a demo!\r\n"

# Padding to 512 byte with 0
.= 512
