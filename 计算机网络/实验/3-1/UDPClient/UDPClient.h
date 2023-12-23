#pragma once

#include <WinSock2.h>
#include <ws2tcpip.h>
#include <iostream>
#include <string>
#include <fstream>
#include <Windows.h>
#include <chrono>
#include <thread>
#include <random>
#include "UDPPacket.h"

#pragma comment(lib, "ws2_32.lib")

#define BUFFER_SIZE (DATA_SIZE + sizeof(Header))
#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS

enum Level { INFO, WARN, ERR, RECV, SEND, NOP };

using std::string;
using std::cout;
using std::endl;
using std::to_string;
using std::cin;

#define MAX_ATTEMPTS 8

class UDPClient {
public:
    UDPClient(const std::string& serverIP, UINT serverPort);
    ~UDPClient();

    void SendFile(const std::string& filePath);
    void Print(const string& info, Level lv = NOP);

private:
    string serverIP;
    UINT serverPort;
    SOCKET clientSocket;
    sockaddr_in serverAddr;
    bool isconnected = false;
    uint32_t currentSeqNum = 0;
    uint32_t ackNum = 0;
    uint64_t totalBytesSent = 0;                     // 发送的总字节数
    std::chrono::steady_clock::time_point startTime; // 发送开始时间

    string GetCurrTime();
    void initializeWinsock();
    void createSocket();
    void configureServerAddress();
    void handshake();
    void waveHand();
    void sendPacket(UDPPacket& packet);
    void sendACK();
    void receiveACK();
    void sendFileData(const string& filePath);
    void sendStartFlag();
    void sendEndFlag();
    void sendFilePacket(const char* data, uint16_t length);
    bool waitForPacket(uint32_t expectedFlag, uint32_t expectedSeqNum = UINT_MAX, int timeoutMs = 500);
    void PrintPacketInfo(const UDPPacket& packet, Level lv);
};
