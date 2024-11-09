#include <inttypes.h>
#include <stdio.h>
#include <openssl/sha.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#define BLOOM_K 32
typedef long long ll;

typedef struct bloom {
    ll* filter;
    unsigned bits;
} bloom;

void init_filter(bloom* b, unsigned elements);

void uninit_filter(bloom* b);

bool present(bloom* b, char* str, unsigned len);

void insert(bloom* b, char* str, unsigned len);

void flip(bloom* b, unsigned index);

bool is_flipped(bloom* b, unsigned index);

unsigned murmur3(uint8_t* str, unsigned len, unsigned seed);

unsigned murmur_xor(unsigned k);

unsigned sha256(unsigned char* str, unsigned len);