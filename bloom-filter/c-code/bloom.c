#include "bloom.h"

void init_filter(bloom* b, unsigned elements) {
    elements *= BLOOM_K;
    b->bits = elements;
    //  ceil(bits/64)
    unsigned longs = (elements/64) + !!(elements%64);
    b->filter = (ll*)malloc(longs*sizeof(ll));
    memset(b->filter,0,longs*sizeof(ll));
}

void uninit_filter(bloom* b) {
    free(b->filter);
}

bool present(bloom* b, char* str, unsigned len) {
    unsigned h1 = murmur3((uint8_t*)str,len,0);
    unsigned h2 = sha256((unsigned char*)str,len);
    if(!is_flipped(b,h1) || !is_flipped(b,h2))
        return 0;
    for(int i = 0; i < (BLOOM_K-2); ++i) {
        unsigned hi = h1 + i*h2;
        if(!is_flipped(b,hi))
            return 0;
    }
    return 1;
}

void insert(bloom* b, char* str, unsigned len) {
    unsigned h1 = murmur3((uint8_t*)str,len,0);
    unsigned h2 = sha256((unsigned char*)str,len);
    flip(b,h1);
    flip(b,h2);
    //  run hash gaultlet, flip all
    for(int i = 0; i < (BLOOM_K-2); ++i) {
        unsigned hi = h1 + i*h2;
        flip(b,hi);
    }
}

void flip(bloom* b, unsigned index) {
    index %= b->bits;
    b->filter[index/64] |= (1<<(index%64));
}

bool is_flipped(bloom* b, unsigned index) {
    index %= b->bits;
    return (b->filter[index/64] & (1<<(index%64))); 
}

unsigned murmur3(uint8_t* str, unsigned len, unsigned seed) {
    //  seed
    unsigned h = seed;
    unsigned k;
    //  all chunks of 4
    for(int i = len>>2; i; --i) {
        memcpy(&k,str,sizeof(unsigned));
        str += sizeof(unsigned);
        h ^= murmur_xor(k);
        h = (h<<13)|(h>>19);
        h = (h*5)+0xe6546b64;
    }
    //  all leftover
    k = 0;
    for(int i = len&3; i; --i) {
        k <<= 8;
        k |= str[i-1];
    }
    h ^= murmur_xor(k);
    //  final calculations
    h ^= len;
    h ^= (h>>16);
    h *= 0x85ebca6b;
    h ^= (h>>13);
    h *= 0xc2b2ae35;
    h ^= (h>>16);
    return h;
}

unsigned murmur_xor(unsigned k) {
    k *= 0xcc9e2d51;
    k = (k<<15)|(k>>17);
    k *= 0x1b873593;
    return k;
}

unsigned sha256(unsigned char* str, unsigned len) {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256(str,len,hash);
    unsigned h;
    memcpy(&h,hash,sizeof(unsigned));
    return h;
}