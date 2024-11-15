#include "bit.h"

bit* bit_init(int n) {
    bit* b = (bit*)malloc(sizeof(bit));
    b->n = n++;
    b->c = malloc(sizeof(int)*n);
    memset(b->c,0,sizeof(int)*n);
    return b;
}

void bit_update(bit* b, int i, int d) {
    ++i;
    while(i <= b->n)
        b->c[i] += d,
        i += (i&-i);
}

int bit_query(bit* b, int i) {
    ++i;
    int ret = 0;
    while(i > 0)
        ret += b->c[i],
        i -= (i&-i);
    return ret;
}

int bit_range(bit* b, int l, int h) {
    return bit_query(b,h)-bit_query(b,l-1);
}

void clear(bit* b) {
    free(b->c);
}