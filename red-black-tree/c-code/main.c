#include "rb.h"

int main(int argc, char* argv[]) {
    printf("%d\n",argc);
    printf("%s\n",argv[0]);
    node* n = malloc(sizeof(node));
    free(n);
    return 0;
}