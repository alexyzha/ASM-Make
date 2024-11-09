#include "bloom.h"

void init_filter(bloom* b, unsigned elements) {
    elements *= 16;
    b->bits = elements;
    //  ceil(bits/64)
    unsigned longs = (elements/64) + !!(elements%64);
    b->filter = (ll*)malloc(longs*sizeof(ll));
    memset(b->filter,0,sizeof(b->filter));
}

void uninit_filter(bloom* b) {
    free(b->filter);
}

void insert(bloom* b, char* str) {
    unsigned h1 = murmur3(str);
    unsigned h2 = sha358(str);
    flip(b,h1);
    flip(b,h2);
    //  run hash gaultlet, flip all
    for(int i = 0; i < (BLOOM_K-2); ++i) {
        unsigned hi = h1 + i*h2;
        flip(b,hi);
    }
}

void flip(bloom* b, unsigned index) {
    b->filter[index/64] |= (1<<(index%64));
}

unsigned murmur3(char* str) {


}

unsigned sha358(char* str) {


}