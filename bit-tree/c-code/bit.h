#include <stdio.h>
#include <stdlib.h>
#include <string.h>                         //  malloc
#include <assert.h>

typedef struct bit {
    int* c;
    int n;
} bit;

bit* bit_init(int n);

void bit_update(bit* b, int i, int d);

int bit_query(bit* b, int i);

int bit_range(bit* b, int l, int h);

void clear(bit* b);