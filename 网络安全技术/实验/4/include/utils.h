#ifndef UTILS_H
#define UTILS_H

#include <string>

bool isValidIP(const std::string& ip);
bool isValidPort(int port);
void log(const std::string& message);
unsigned short in_cksum(unsigned short *addr, int len);

#endif