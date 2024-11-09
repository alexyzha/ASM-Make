CC = gcc
CFLAGS = -Wall -Wextra -std=c11
LDFLAGS = -lssl -lcrypto
OBJDIR = obj
TARGET = $(OBJDIR)/main
SRCS = main.c bloom.c
OBJS = $(patsubst %.c,$(OBJDIR)/%.o,$(SRCS))

all: $(TARGET) nmrun

$(TARGET): $(OBJS) | $(OBJDIR)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS)

$(OBJDIR)/%.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR):
	mkdir -p $(OBJDIR)

clean:
	rm -rf $(OBJDIR) $(TARGET)

vgrun:
	valgrind --leak-check=full ./obj/main

nmrun:
	./obj/main