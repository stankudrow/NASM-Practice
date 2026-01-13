ENTRY_POINT := main

# `make run NAME=01_putchars` - compiles "01_putchars" file
# `make run` -> defaults to :00_putstr" file
NAME ?= 00_putstr

.PHONY: all clean debug fclean re run

all: $(NAME).out

$(NAME).o: $(NAME).asm
	nasm -f elf64 -g -F dwarf $(NAME).asm -o $(NAME).o

# https://eli.thegreenplace.net/2012/08/13/how-statically-linked-programs-run-on-linux
$(NAME).out: $(NAME).o
	ld -e $(ENTRY_POINT) -o $(NAME).out $(NAME).o

run: $(NAME).out
	./$(NAME).out

debug: $(NAME).out
	gdb ./$(NAME).out

clean:
	rm -f *.o

fclean: clean
	rm -f *.out

re: fclean all
