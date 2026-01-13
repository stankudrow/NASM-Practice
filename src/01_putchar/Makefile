NAME := putchar

.PHONY: all clean debug fclean re run

all: $(NAME).out

$(NAME).o: $(NAME).asm
	nasm -f elf64 -g -F dwarf $(NAME).asm -o $(NAME).o

$(NAME).out: $(NAME).o
	ld -o $(NAME).out $(NAME).o

run: $(NAME).out
	./$(NAME).out

debug: $(NAME).out
	gdb ./$(NAME).out

clean:
	rm -f $(NAME).o

fclean: clean
	rm -f $(NAME).out

re: fclean all
