#include "uf.h"

uf* uf_init(int size) {
    uf* ret = (uf*)malloc(sizeof(uf));
    ret->p = malloc(sizeof(int)*size);
    ret->h = malloc(sizeof(int)*size);
    for(int i = 0; i < size; ++i)
        ret->p[i] = i,
        ret->h[i] = 1;
    ret->size = size;
    return ret;
}

int find(uf* u, int x) {
    if(u->p[x] == x)
        return x;
    return u->p[x] = find(u,u->p[x]);
}

void join(uf* u, int x, int y) {
    int px = u->p[x],
        py = u->p[y];
    if(px == py)
        return;
    if(u->h[px] >= u->h[py])
        u->p[py] = u->p[px],
        u->h[px] += (u->h[px] == u->h[py]);
    else
        u->p[px] = u->p[py];
}

int con(uf* u, int x, int y) {
    return find(u,x) == find(u,y);
}

void clear(uf* u) {
    free(u->p);
    free(u->h);
}