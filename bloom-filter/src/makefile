OUT = ./obj/bloom
OBJ = ./obj
SRC = bloom.asm
NASM_FLAGS = -f elf64
GCC_FLAGS = -m64 -nostartfiles -no-pie -lc -g

all: $(OBJ) $(OUT) run

$(OBJ):
	mkdir -p $(OBJ)

$(OUT).o: $(SRC) | $(OBJ)
	nasm $(NASM_FLAGS) -o $(OUT).o $(SRC)

$(OUT): $(OUT).o
	gcc $(GCC_FLAGS) -o $(OUT) $(OUT).o -lm

run: $(OUT)
	./$(OUT)

clean:
	rm -f $(OUT) $(OUT).o
