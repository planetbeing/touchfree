CC=arm-apple-darwin-gcc
LD=$(CC)
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit -framework GraphicsServices

all:	ssh

ssh:	ssh.o sshApplication.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
		rm -f *.o ssh
