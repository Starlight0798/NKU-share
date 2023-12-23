#pragma once

#include <fstream>
#include <vector>
#include <random>
#include <vector>
#include "UDP.h"

#define BUFFER_SIZE (DATA_SIZE + sizeof(Header))
#define MAX_ATTEMPTS 10

class UDPServer : public UDP {
public:
    UDPServer(UINT port);
    ~UDPServer();

    void Start();
    void Stop();

private:
    UINT port;
    SOCKET serverSocket;
    sockaddr_in serverAddr;
    sockaddr_in clientAddr;
    std::ofstream outFile;
    bool isconnect = false;
    uint32_t ackNum = 0;
    uint32_t lastack = 0;
    uint32_t currSeq = 0;
    uint32_t exptSeq = 0;
    uint64_t totalBytesRecv = 0;                     // 接收的总字节数

    void receiveData();                   
    void writeData(const char* data, uint16_t length);
    void sendPacket(uint32_t flags, uint32_t seq, uint32_t ack = UINT_MAX, const char* data = nullptr, uint16_t length = 0);
    void openFile(const std::string& filename);
    void closeFile();
    void handshake();
    void waveHand();
    bool waitForPacket(uint32_t expectedFlag);
    bool receivePacket(UDPPacket& packet);
};
