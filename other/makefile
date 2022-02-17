all: testcase_gen

inserter:
	gcc -Wall -Wextra -c inserter.c -o tc_lib
	strip --strip-unneeded tc_lib

testcase_gen: inserter
	gcc -Wall -Wextra tc_gen.c tc_lib -o tc_gen
