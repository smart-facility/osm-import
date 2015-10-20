osmconvert:	osmconvert.c
	cc osmconvert.c -lz -O3 -o osmconvert

install:	osmconvert
	mv osmconvert /usr/local/bin
