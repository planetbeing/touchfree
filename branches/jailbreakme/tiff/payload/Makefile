CC=arm-apple-darwin-gcc
LD=arm-apple-darwin-gcc
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit

UI_OBJS = payload.o PayloadApplication.o
UTIL_OBJS = utilities.o patch-graphics.o
UNZ_OBJS = miniunz.o unzip.o ioapi.o ~/zlib-1.2.3/libz.a
ALL_OBJS = $(UI_OBJS) $(UTIL_OBJS) $(UNZ_OBJS)

all:	Payload

%.o:	%.c
	$(CC) $(CFLAGS) -pedantic -c $< -o $@

%.o:	%.m
	$(CC) $(CFLAGS) $(CPPFLAGS) -pedantic -c $< -o $@


Payload:	$(ALL_OBJS)
		$(LD) $(LDFLAGS) -pedantic -o $@ $(ALL_OBJS)

clean:
		rm -f *.o
