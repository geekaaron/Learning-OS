
AS = as
LD = ld
OBJCOPY = objcopy
QEMU = qemu-system-i386
BOCHS = bochs

LDFLAGS += -Ttext 0 -m elf_i386 -s

.PHONY: all, clean, run

all: image

bootsect: bootsect.s
	@$(AS) --32 -o bootsect.o $<
	@$(LD) $(LDFLAGS) -e _bootsect -o $@ bootsect.o

image: bootsect
	@$(OBJCOPY) -O binary -S -j .text $< $@

run-qemu:
	@$(QEMU) -boot a -fda image

run-bochs:
	@$(BOCHS) -f bochsrc

clean:
	@rm *.o bootsect image
