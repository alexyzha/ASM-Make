#include "uf.h"

int main(int argc, char* argv[]) {
    uf* u = NULL;
    u = uf_init(10);
    join(u,1,2);
    printf("%d\n",con(u,1,2));
    printf("%d\n",find(u,2));
    clear(u);
    free(u);
    u = NULL;
    return 0;
}