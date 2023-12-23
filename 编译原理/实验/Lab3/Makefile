SRC_PATH ?= src
INC_PATH += include
BUILD_PATH ?= build
TEST_PATH ?= test
OBJ_PATH ?= $(BUILD_PATH)/obj
BINARY ?= $(BUILD_PATH)/compiler
SYSLIB_PATH ?= sysyruntimelibrary

INC = $(addprefix -I, $(INC_PATH))
SRC = $(shell find $(SRC_PATH)  -name "*.cpp")
CFLAGS = -O2 -g -Wall -Werror $(INC)
FLEX ?= $(SRC_PATH)/lexer.l
LEXER ?= $(addsuffix .cpp, $(basename $(FLEX)))
SRC += $(LEXER)
OBJ = $(SRC:$(SRC_PATH)/%.cpp=$(OBJ_PATH)/%.o)

TESTCASE = $(shell find $(TEST_PATH) -name "*.sy")
OUTPUT_LAB3 = $(addsuffix .toks, $(basename $(TESTCASE)))

.phony:all app run gdb test clean 

all:app

$(LEXER):$(FLEX)
	@flex -o $@ $<

$(OBJ_PATH)/%.o:$(SRC_PATH)/%.cpp
	@mkdir -p $(OBJ_PATH)
	@g++ $(CFLAGS) -c -o $@ $<

$(BINARY):$(OBJ)
	@g++ -O2 -g -o $@ $^

app:$(LEXER) $(BINARY)

run:app
	@$(BINARY) -o example.toks -t example.sy

gdb:app
	@gdb $(BINARY)

$(OBJ_PATH)/lexer.o:$(SRC_PATH)/lexer.cpp
	@mkdir -p $(OBJ_PATH)
	@g++ $(CFLAGS) -c -o $@ $<

$(TEST_PATH)/%.toks:$(TEST_PATH)/%.sy
	@$(BINARY) $< -o $@ -t

test:app $(OUTPUT_LAB3)

clean:
	@rm -rf $(BUILD_PATH) $(LEXER) $(OUTPUT_LAB3) *.toks *.out
