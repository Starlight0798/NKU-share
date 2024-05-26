#include "../include/utils.h"
#include <iostream>
#include <regex>

// IP地址验证函数
bool isValidIP(const std::string& ip) {
    std::regex ipPattern("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$");
    return std::regex_match(ip, ipPattern);
}

// 端口号验证函数
bool isValidPort(int port) {
    return (port > 0 && port <= 65535);
}

// 日志函数
void log(const std::string& message) {
    std::cout << message << std::endl;
}

// 计算校验和的函数
unsigned short in_cksum(unsigned short *addr, int len) {
    int sum = 0;
    unsigned short *w = addr;
    unsigned short answer = 0;

    while (len > 1) {
        sum += *w++;
        len -= 2;
    }

    if (len == 1) {
        *(unsigned char *)(&answer) = *(unsigned char *)w;
        sum += answer;
    }

    sum = (sum >> 16) + (sum & 0xFFFF);
    sum += (sum >> 16);
    answer = ~sum;
    return answer;
}