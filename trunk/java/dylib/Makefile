CC=arm-apple-darwin-gcc

all:	planetbeing.dylib

%.o:	%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -fno-common -c $< -fvisibility=hidden -o $@

planetbeing.dylib:	planetbeing.o
			$(CC) $(CFLAGS) $(CPPFLAGS) -dynamiclib -std=gnu99 -o $@ $<

clean:
		rm -f *.dylib *.o
