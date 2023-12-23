.PHONY:test,clean
test:
	yacc yacc_1_2.y
	gcc y.tab.c -o y12.out
	yacc yacc_3.y
	gcc y.tab.c -o y3.out
clean:
	rm -fr *.out