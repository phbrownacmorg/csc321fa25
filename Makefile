%.obj : %.asm
	nasm -g -f elf64 -o $@ $<

%.exe : %.obj std321.obj
	ld -m i386pep -L C:\Windows\System32 -e start $< std321.obj -lkernel32 -luser32 -o $@

%.exe : %.c
	gcc -g -o $@ $<

.PHONY: clean
clean:
	del *.obj
	del *.exe
