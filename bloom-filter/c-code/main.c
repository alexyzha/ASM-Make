#include "bloom.h"

void ins_in(bloom* b, int ct) {
    char n[16] = "i";
    while(ct--) {
        //  make random str
        for(int i = 1; i < 16; ++i)
            n[i] = (char)(rand() % 256);
        //  insert
        insert(b,(char*)n,16);
    }
    printf("\nInsert done\n");
}

void test_out(bloom* b, int ct) {
    char o[16] = "o";
    int collide = 0, 
        total = ct;
    while(ct--) {
        //  make random str
        for(int i = 1; i < 16; ++i)
            o[i] = (char)(rand() % 256);
        //  count collisions
        collide += present(b,(char*)o,16);
    }
    double percent = (double)collide/total*100.0;
    printf("Collision%%: %f%%\n",percent);
    printf("Collisions: %d/%d\n\n",collide,total);
}

int main(int argc, char* argv[]) {
    bloom* b = malloc(sizeof(bloom));
    int NUM = 100000;
    init_filter(b,NUM);
    unsigned seed = 0x0a55f00d;
    srand(seed);
    //  items in filter start with "i"
    //  items out of filter start with "o"
    ins_in(b,NUM);
    test_out(b,NUM);
    uninit_filter(b);
    free(b);
    return 0;
}