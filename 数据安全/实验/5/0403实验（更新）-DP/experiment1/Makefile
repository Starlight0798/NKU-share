CC = gcc
TARGET = testraw
OBJS = csvpackage.o laplace.o testraw.o
INCLUDE = -I./include
all:testraw testhist
$(TARGET):csvpackage.o laplace.o testraw.o
	$(CC) csvpackage.o laplace.o testraw.o -o $(TARGET)  -lm
testhist:csvpackage.o laplace.o testhist.o 
	$(CC) csvpackage.o laplace.o testhist.o -o testhist -lm
csvpackage.o:csvpackage.c
	$(CC) $(INCLUDE) -c csvpackage.c 
laplace.o:laplace.c
	$(CC) $(INCLUDE) -c laplace.c -lm
testraw.o:testraw.c
	$(CC) $(INCLUDE) -c testraw.c 
testhist.o:testhist.c
	$(CC) $(INCLUDE) -c testhist.c


 .PHONY:clean
 clean:
	 rm *.o testraw testhist

