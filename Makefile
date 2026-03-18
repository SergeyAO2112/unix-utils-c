CC = gcc
CFLAGS = -Wall -Werror -Wextra -std=c11 
SRC = cat.c 
TARGET = s21_cat

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(SRC) $(CFLAGS) -o $(TARGET)

clean:
	rm -f $(TARGET)