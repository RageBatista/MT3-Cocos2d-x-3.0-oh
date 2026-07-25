#include <stdio.h>

int __swbuf(int c, FILE* stream) {
    return fputc(c, stream);
}

int __srget(FILE* stream) {
    return fgetc(stream);
}
