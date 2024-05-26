# Makefile

# 编译器设置
CC = g++
CFLAGS = -Wall -Wextra -Werror -std=c++11 -Iinclude
LDFLAGS = -lpthread

# 目标文件夹
OBJ_DIR = obj
BIN_DIR = bin
SRC_DIR = src

# 目标文件
TARGET = $(BIN_DIR)/Scaner

# 源文件
SRCS = $(SRC_DIR)/Scaner.cpp \
       $(SRC_DIR)/Ping.cpp \
       $(SRC_DIR)/TCPConnectScan.cpp \
       $(SRC_DIR)/TCPSYNScan.cpp \
       $(SRC_DIR)/TCPFINScan.cpp \
       $(SRC_DIR)/UDPScan.cpp \
       $(SRC_DIR)/utils.cpp

# 生成目标文件列表
OBJS = $(SRCS:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.o)

# 默认目标
all: $(BIN_DIR) $(OBJ_DIR) $(TARGET)

# 生成可执行文件
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# 生成目标文件
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CC) $(CFLAGS) -c -o $@ $<

# 创建目标文件夹
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# 清理中间文件和可执行文件
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)

# 伪目标，防止与实际文件名冲突
.PHONY: all clean
