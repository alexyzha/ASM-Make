#include "avl.h"

int main(int argc, char* argv[]) {
    node* root = NULL;
    
    for(int i = 0; i < 1; ++i) {
        root = avl_insert(rand() % 1000000,root);
    }

    print(root);
    char* b = "";
    printf("%s\n",b);
    return 0;
}