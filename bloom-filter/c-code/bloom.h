#define BLOOM_K 16
typedef long long ll;

typedef struct bloom {
    ll* filter;
    unsigned bits;
} bloom;