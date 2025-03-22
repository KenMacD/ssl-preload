CC = gcc
PKG_CONFIG = pkg-config

OPENSSL_CFLAGS = $(shell $(PKG_CONFIG) --cflags openssl)
OPENSSL_LIBS = $(shell $(PKG_CONFIG) --libs openssl)

CFLAGS = -Wall -fPIC -g $(OPENSSL_CFLAGS)
LDFLAGS = -shared -ldl $(OPENSSL_LIBS)

all: libssl_preload.so

libssl_preload.so: ssl_preload.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -f libssl_preload.so
