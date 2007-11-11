CC=arm-apple-darwin-gcc

all:	planetbeing.dylib ldpatch springpatch

%.o:	%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -fno-common -c $< -fvisibility=hidden -o $@

planetbeing.dylib:	planetbeing.o
			$(CC) $(CFLAGS) $(CPPFLAGS) -dynamiclib -std=gnu99 -o $@ $<

ldpatch:	ldpatch.o patch.o
		$(CC) $(CFLAGS) $(CPPFLAGS) -framework CoreFoundation -framework Foundation -std=gnu99 -o $@ ldpatch.o patch.o

springpatch:	sbpatch.o patch.o
		$(CC) $(CFLAGS) $(CPPFLAGS) -framework CoreFoundation -framework Foundation -std=gnu99 -o $@ sbpatch.o patch.o

clean:
		rm -f ldpatch springpatch *.dylib *.o
