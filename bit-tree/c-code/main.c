#include "bit.h"

int main(int argc, char* argv[]) {
    printf("{%d} {%s}\n",argc,argv[0]);
    bit* b = NULL;
    b = bit_init(100);
    for(int i = 25; i <= 75; i+=5)
        bit_update(b,i,1);
    printf("%d\n",bit_range(b,25,75));
    printf("%d\n",bit_range(b,50,75));
    clear(b);
    free(b);
    b = NULL;
    return 0;
}