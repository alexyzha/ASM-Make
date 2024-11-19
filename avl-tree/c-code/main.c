#include "avl.h"

int main(int argc, char* argv[]) {
    node* root = NULL;
    printf("#======================#\nCatch higher left:\n");
        root = new_node(5);
        root->left = new_node(7);
        root->height = 2;
        assert(validate(root) == 0);
        assert(check_heights(root) == 1);
        printf("\033[0;32mPassed\n\033[0m");
        clear(root);
        root = NULL;
    printf("#======================#\nCatch lower right:\n");
        root = new_node(7);
        root->right = new_node(5);
        root->height = 2;
        assert(validate(root) == 0);
        assert(check_heights(root) == 1);
        printf("\033[0;32mPassed\n\033[0m");
        clear(root);
        root = NULL;
    printf("#======================#\nCatch incorrect height:\n");
        root = new_node(4);
        root->right = new_node(5);
        root->height = 1;
        assert(validate(root) == 1);
        assert(check_heights(root) == 0);
        printf("\033[0;32mPassed\n\033[0m");
        clear(root);
        root = NULL;
    printf("#======================#\nCatch imbalance:\n");
        root = new_node(4);
        root->right = new_node(5);
        root->height = 3;
        root->right->height = 2;
        root->right->right = new_node(6);
        assert(validate(root) == 0);
        assert(check_heights(root) == 1);
        printf("\033[0;32mPassed\n\033[0m");
        clear(root);
        root = NULL;
    /* perfect dist testing
    root = avl_insert(4,root);
    root = avl_insert(2,root);
    root = avl_insert(6,root);
    root = avl_insert(1,root);
    root = avl_insert(3,root);
    root = avl_insert(5,root);
    root = avl_insert(7,root);
    root = avl_delete(4,root);                  //  case 3
    root = avl_delete(6,root);                  //  case 2
    root = avl_delete(2,root);                  //  case 3
    root = avl_delete(1,root);                  //  case 1
    */
    for(int tct = 1; tct <= 10; ++tct) {        //  insert tests
        int seed = tct * 0x6ab29cf3;
        seed = (tct<<13)|(tct>>19);
        seed ^= 0x12a596b2;
        seed = (tct<<17)|(tct>>15);
        srand(seed);
        printf("#======================#\nInsert test %d {\033[0;35m%d\033[0m}:\n",tct,seed);
        int ct = 0;
        for(int i = 0; i < 10000; ++i) {
            root = avl_insert(rand()%2000000000,root);
            ct += (validate(root) & check_heights(root));
        }
        printf(ct == 10000 ? "\033[0;32m" : "\033[0;31m");
        printf("%d/10000\n",ct);
        printf("\033[0m");
        clear(root);
        root = NULL;
    }
    int in[10000];
    for(int tct = 1; tct <= 10; ++tct) {        //  delete tests
        int ct = 0;
        int left = 10000;
        int seed = tct * 0x6ab29cf3;
        seed = (tct<<13)|(tct>>19);
        seed ^= 0x12a596b2;
        seed = (tct<<17)|(tct>>15);
        srand(seed);
        printf("#======================#\nDelete test %d {\033[0;35m%d\033[0m}:\n",tct,seed);
        memset(in,0,sizeof(in));
        for(int i = 0; i < 10000; ++i)
            root = avl_insert(i,root);
        while(left--) {
            int sel = rand() % 10000;
            if(left > 1000) {
                while(in[sel])
                sel = rand() % 10000;  
            } else for(int j = 0; j < 10000; ++j) {
                if(!in[j]) {
                    sel = j;
                    break;
                }
            }
            in[sel] = 1;
            ct += (validate(root) & check_heights(root));
        }
        printf(ct == 10000 ? "\033[0;32m" : "\033[0;31m");
        printf("%d/10000\n",ct);
        printf("\033[0m");
        clear(root);
        root = NULL;
    }
    printf("#======================#\n");
    printf("{\033[0;35m%d\033[0m} {\033[0;35m%s\033[0m}\n",argc,argv[0]);
    printf("#======================#\n");
    return 0;
}