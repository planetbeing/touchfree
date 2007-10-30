You need the iphone toolchain from http://code.google.com/p/iphone-dev/

You also need to compile a static zlib library. The Makefile assumes it is stored in ~/zlib-1.2.3

arm-apple-darwin-ranlib must be run on ~/zlib-1.2.3/libz.a, which is not automatically done

PayloadApplication.m contains a reference to "http://www.slovix.com/touchfree/jb/root.zip". That must be changed if the resources archive is uploaded to any other location.
