# GNU Make Manual: https://www.gnu.org/software/make/manual/make.html

# <var_name> := <value>
NAME := hello

# $(NAME) means "get the value which is assigned to the variable NAME".

# The command `make` invokes the first rule, here `all`.
# The `all` rule checks if the $(NAME) (i.e. hello) file exists.
# If not, it proceeds to the `hello` rule which is expanded from the $(NAME).
all: $(NAME)

# If the hello.o file exists, then the `ld -o hello hello.o` command runs.
# Otherwise, Make seeks for the `hello.o` rule.
$(NAME): $(NAME).o
	ld -o $(NAME).out $(NAME).o

# Since the `hello.asm` file exists, then the `nasm -f ...` line executes.
hello.o: hello.asm
	nasm -f elf64 $(NAME).asm -o $(NAME).o

clean:  # removes hello.o file anyway
	rm -f $(NAME).o

# The `fclean` rule invokes the `clean` rule as a prerequisite.
# So the `clean` logic applies first, then the `rm -f hello` command in the `fclean` section.
fclean: clean
	rm -f $(NAME).out

# first `fclean`, then `all` and that is what `re` is
re: fclean all

# The PHONY section contains names which are purely regarded as the names of rules for Make.
# Suppose there is a file with name "clean", just like the rule in this Makefile.
# When invoking clean rule by running `make clean`, Make finds the "clean" file.
# Since the latter exists and remains untouched, there is no need to do anything.
# The name of the "clean" file shadows the name of the `clean` rule.
# But if `clean` is a PHONY name, even the presense of a "clean" file will not be a hindrance.
# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: all clean fclean re
