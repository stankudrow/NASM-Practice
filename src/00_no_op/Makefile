# GNU Make Manual: https://www.gnu.org/software/make/manual/make.html

NAME := noop

# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: all clean fclean re run

# https://ru.wikipedia.org/wiki/Executable_and_Linkable_Format
$(NAME).o: $(NAME).asm
	nasm -f elf64 $(NAME).asm -o $(NAME).o

$(NAME).out: $(NAME).o
	ld -o $(NAME).out $(NAME).o

all: $(NAME).out

run: $(NAME).out
	./$(NAME).out

clean:
	rm -f $(NAME).o

fclean: clean
	rm -f $(NAME).out

re: fclean all
