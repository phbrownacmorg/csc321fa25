%.obj : %.asm
	nasm -g -f win64 -o $@ $<

%.exe : %.obj std321.obj
	ld -L C:\Windows\System32 -e start $< std321.obj -lkernel32 -luser32 -o $@

%.exe : %.c
	gcc -g -o $@ $<

.PHONY: clean
clean:
	del *.obj
	del *.exe
