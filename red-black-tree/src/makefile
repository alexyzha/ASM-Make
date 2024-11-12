OUT = ./obj/rb
OBJ = ./obj
SRC = rb.asm
NASM_FLAGS = -f elf64
GCC_FLAGS = -m64 -nostartfiles -no-pie -lc -lm -g

all: $(OBJ) $(OUT) run

$(OBJ):
	mkdir -p $(OBJ)

$(OUT).o: $(SRC) | $(OBJ)
	nasm $(NASM_FLAGS) -o $(OUT).o $(SRC)

$(OUT): $(OUT).o
	gcc $(GCC_FLAGS) -o $(OUT) $(OUT).o

run: $(OUT)
	./$(OUT)

clean:
	rm -f $(OUT) $(OUT).o

vgrun:
	valgrind --leak-check=full ./obj/rb