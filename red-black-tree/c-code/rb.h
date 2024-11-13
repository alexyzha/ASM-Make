#include <stdio.h>
#include <stdlib.h>
#include <string.h>                         //  malloc

typedef struct node {
    struct node* parent;                    //  qword on x86_64/arm64
    struct node* left;
    struct node* right;
    int val;                                //  dword
    unsigned char color;                    //  buffer optimization, byte, 0 = black, 1 = red
} node;

void rb_find(node* root, int nval);

void rb_insert(node* root, int nval);

void rb_remove(node* root, int rval);

void rb_balance(node* cur);

void rb_lrotate(node* cur);

void rb_rrotate(node* cur);

/*---------------*
 |  For testing  |
 *---------------*/

void rb_validate(node* root);

void check_black_counts(node* root, unsigned char* match);

unsigned char check_double_red(node* root);

unsigned char check_bst(node* root);