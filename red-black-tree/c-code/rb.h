#include <stdio.h>
#include <stdlib.h>
#include <string.h>                         //  malloc

typedef struct node {
    struct node* parent,                    //  qword on x86_64/arm64
               * left,  
               * right;                     
    void* val;
    unsigned char color;                    //  buffer optimization
} node;

void rb_find(node* root, void* nval);

void rb_insert(node* root, void* nval);

void rb_remove(node* root, void* rval);

void rb_balance(node* cur);

void rb_validate(node* root);               //  for testing