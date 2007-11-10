CC=arm-apple-darwin-gcc

all:	planetbeing.dylib ldpatch

%.o:	%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -fno-common -c $< -fvisibility=hidden -o $@

planetbeing.dylib:	planetbeing.o
			$(CC) $(CFLAGS) $(CPPFLAGS) -dynamiclib -std=gnu99 -o $@ $<

ldpatch:	ldpatch.o
		$(CC) $(CFLAGS) $(CPPFLAGS) -framework CoreFoundation -framework Foundation -std=gnu99 -o $@ $<

clean:
		rm -f *.dylib *.o
