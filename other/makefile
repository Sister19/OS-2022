all: testcase_gen

inserter:
	gcc -Wall -Wextra -c inserter.c
	strip --strip-unneeded inserter.o

testcase_gen: inserter
	gcc -Wall -Wextra tc_gen.c inserter.o -o tc_gen
