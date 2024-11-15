CC = gcc
C_FLAGS = -Wall -Wextra -std=c11
OBJDIR = obj
TARGET = $(OBJDIR)/main
SRCS = main.c seg.c
OBJS = $(patsubst %.c,$(OBJDIR)/%.o,$(SRCS))

all: $(TARGET) nmrun

$(TARGET): $(OBJS) | $(OBJDIR)
	$(CC) $(C_FLAGS) -o $(TARGET) $(OBJS)

$(OBJDIR)/%.o: %.c | $(OBJDIR)
	$(CC) $(C_FLAGS) -c $< -o $@

$(OBJDIR):
	mkdir -p $(OBJDIR)

clean:
	rm -rf $(OBJDIR) $(TARGET)

vgrun:
	valgrind --leak-check=full --undef-value-errors=no ./obj/main

nmrun:
	./obj/main