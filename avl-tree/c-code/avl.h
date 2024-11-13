#include <stdio.h>
#include <stdlib.h>
#include <string.h>                         //  malloc
#include <assert.h>

typedef struct node {
    struct node* left;                      //  qword
    struct node* right;
    int val;                                //  dword
    int height;
} node;

node* new_node(int i);

node* avl_find(int i, node* tree);

node* lrotate(node* x);

node* rroate(node* x);

int balance(node* x);

void fix_height(node* x);

node* avl_insert(int i, node* tree);

void print(node* tree);

int validate(node* tree);