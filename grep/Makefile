CC = gcc
CFLAGS = -Wall -Werror -Wextra -std=c11 
SRC = grep.c 
TARGET = s21_grep

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(SRC) $(CFLAGS) -o $(TARGET)

clean:
	rm -f $(TARGET)