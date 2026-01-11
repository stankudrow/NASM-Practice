# GNU Make Manual: https://www.gnu.org/software/make/manual/make.html

# To compile print_lines: `make TARGET=01_print_lines`.
# Note: The ?= operator sets TARGET to print_char only if not already defined (e.g., by make TARGET=...).
TARGET ?= 00_print_char

NAME := $(TARGET)

# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: all clean fclean re run

$(NAME).o: $(NAME).asm
	nasm -f elf64 $(NAME).asm -o $(NAME).o

$(NAME).out: $(NAME).o
	ld -o $(NAME).out $(NAME).o

all: $(NAME).out

run: $(NAME).out
	./$(NAME).out

clean:
	rm -f *.o

fclean: clean
	rm -f *.out

re: fclean all
