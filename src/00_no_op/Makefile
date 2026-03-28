# GNU Make Manual: https://www.gnu.org/software/make/manual/make.html

ROOT_NAME := noop
SUFFIX := asm
OUT_NAME := $(ROOT_NAME)_$(SUFFIX)

# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: all clean fclean re run

# the first rule is default for `make` command
all: $(OUT_NAME).out

# https://ru.wikipedia.org/wiki/Executable_and_Linkable_Format
$(OUT_NAME).o: $(ROOT_NAME).asm
	nasm -f elf64 $(ROOT_NAME).asm -o $(OUT_NAME).o

$(OUT_NAME).out: $(OUT_NAME).o
	ld -o $(OUT_NAME).out $(OUT_NAME).o

run: $(OUT_NAME).out
	./$(OUT_NAME).out

clean:
	rm -f $(OUT_NAME).o

fclean: clean
	rm -f $(OUT_NAME).out

re: fclean all
