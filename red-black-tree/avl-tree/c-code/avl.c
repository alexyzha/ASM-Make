#include "avl.h"
#include "util.h"

node* new_node(int i) {
    node* t = (node*)malloc(sizeof(node));
    t->left = NULL;
    t->right = NULL;
    t->val = i;
    t->height = 1;
    return t;
}

node* avl_find(int i, node* tree) {
    while(tree) {
        if(i == tree->val)
            break;
        tree = i < tree->val ? tree->left : tree->right;
    }
    return tree;
}

node* lrotate(node* x) {
    assert(x->right);
    node* y = x->right;
    node* t = y->left;
    y->left = x;
    x->right = t;
    fix_height(x);
    fix_height(y);
    return y;
}

node* rrotate(node* x) {
    assert(x->left);
    node* y = x->left;
    node* t = y->right;
    y->right = x;
    x->left = t;
    fix_height(x);
    fix_height(y);
    return y;
}

int balance(node* x) {
    if(!x)
        return 0;
    //  - = left imbalance
    //  + = right imbalance
    return (x->right ? x->right->height : 0) - (x->left ? x->left->height : 0);
}

void fix_height(node* x) {
    x->height = max(x->left ? x->left->height : 0,
                    x->right ? x->right->height :0) + 1;
}

node* avl_insert(int i, node* tree) {
    if(!tree)
        tree = new_node(i);
    if(i == tree->val)
        return tree;
    if(i < tree->val)                                                   //  find insert spot
        tree->left = avl_insert(i,tree->left);
    else
        tree->right = avl_insert(i,tree->right);
    fix_height(tree);                                                   //  fix imbalance
    int b = balance(tree);                                              //  rotate
    if(abs(b) > 1) {
        node* next = (b < 0 ? tree->left : tree->right);
        int nb = balance(next);
        if(nb && ((nb&0x80000000)^(b&0x80000000)))                      //  mismatch imbalance sign & nb != 0
            next = (nb < 0 ? rrotate(next) : lrotate(next));
        tree = (b < 0 ? rrotate(tree) : lrotate(tree));                 //  rotate cur
    }
    return tree;
}

node* avl_delete(int i, node* tree) {
    if(!tree)
        return NULL;
    if(i < tree->val)
        tree->left = avl_delete(i,tree->left);
    else if(i > tree->val)
        tree->right = avl_delete(i,tree->right);
    else {                                                              //  found
        if(!tree->left || !tree->right) {                               //  0 & 1 child
            node* t = tree->left ? tree->left : tree->right;
            free(tree);
            return t;
        }
        node* t = tree->right;
        while(t->left)                                                  //  successor
            t = t->left;
        tree->val = t->val;
        tree->right = avl_delete(tree->val,tree->right);
    }
    fix_height(tree);
    int b = balance(tree);                                              //  rotate
    if(abs(b) > 1) {
        node* next = (b < 0 ? tree->left : tree->right);
        int nb = balance(next);
        if(nb && ((nb&0x80000000)^(b&0x80000000)))                      //  mismatch imbalance sign & nb != 0
            next = (nb < 0 ? rrotate(next) : lrotate(next));
        tree = (b < 0 ? rrotate(tree) : lrotate(tree));                 //  rotate cur
    }
    return tree;
}

void clear(node* tree) {
    if(!tree)
        return;
    clear(tree->left);
    clear(tree->right);
    free(tree);
}

void print(node* tree) {
    if(!tree) {
        printf("no tree\n");
        return;
    }
    node* q[15] = {NULL};
    q[0] = tree;
    for(int j = 0; j < 7; ++j) {
        q[j*2+1] = q[j] ? q[j]->left : NULL;
        q[j*2+2] = q[j] ? q[j]->right : NULL;
    }
    for(int i = 0; i < 15; ++i) {
        if(!q[i])
            printf("NULL\n");
        else
            printf("%d %d\n",q[i]->val,q[i]->height);
    }
    printf("\n");
    int yes = validate(tree) & check_heights(tree);
    printf(yes ? "GOOD" : "BAD");
    printf("\n");
}

int validate(node* tree) {
    if(!tree)
        return 1;
    if(tree->left && tree->left->val > tree->val)
        return 0;
    if(tree->right && tree->right->val < tree->val)
        return 0;
    if(abs(balance(tree)) > 1)
        return 0;
    return validate(tree->left) & validate(tree->right);
}

int check_heights(node* tree) {
    if(!tree)
        return 1;
    int r = check_heights(tree->left) & check_heights(tree->right);
    return r & (tree->height == max(tree->right ? tree->right->height : 0,
                                    tree->left ? tree->left->height : 0)+1);
}