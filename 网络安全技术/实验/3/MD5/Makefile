CXX = g++
CXXFLAGS = -Wall -std=c++11
LDFLAGS =

# 目标可执行文件名
TARGET = MD5

# 对象文件
OBJS = MD5.o main.o

# 默认目标
all: $(TARGET)

# 链接目标
$(TARGET): $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $(OBJS)

# 编译源文件到对象文件
MD5.o: MD5.cpp MD5.h
	$(CXX) $(CXXFLAGS) -c MD5.cpp

main.o: main.cpp MD5.h
	$(CXX) $(CXXFLAGS) -c main.cpp

# 清理目标
clean:
	rm -f $(OBJS) $(TARGET)

# 伪目标
.PHONY: all clean
