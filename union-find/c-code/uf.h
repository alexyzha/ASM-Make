#include <stdio.h>
#include <stdlib.h>
#include <string.h>                         //  malloc
#include <assert.h>

typedef struct uf {
    int* p;
    int* h;
    int size;
} uf;

uf* uf_init(int size);

int find(uf* u, int x);

void join(uf* u, int x, int y);

int con(uf* u, int x, int y);

void clear(uf* u);
