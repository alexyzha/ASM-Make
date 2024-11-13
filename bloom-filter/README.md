# Bloom filter in c & asm

- Uses [Kirsch-Mitzenmacher hashing](https://www.eecs.harvard.edu/~michaelm/postscripts/tr-02-05.pdf), essentialy `h_i = h_1 + i * h_2`

- ASM bloom filter uses 14 additional simulated hashes for a `~0.051%` collision rate. Initial 2 hashes are `32 bit murmur3` and `sha256 (first 4 bytes)`

- I wrote `murmur3` by hand but not `sha256` because why :|

- Don't forget `xor rdx, rdx` before dividing :(