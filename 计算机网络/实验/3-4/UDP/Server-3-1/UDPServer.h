#pragma once

#include <WinSock2.h>
#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <random>
#include <chrono>
#include <thread>
#include <Windows.h>
#include "UDPPacket.h"

#pragma comment(lib, "ws2_32.lib")

#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS

enum Level { INFO, WARN, ERR, RECV, SEND, NOP };

#define BUFFER_SIZE (DATA_SIZE + sizeof(Header))
#define MAX_ATTEMPTS 8

using std::string;
using std::cout;
using std::endl;
using std::to_string;
using std::cin;

class UDPServer {
public:
	UDPServer(UINT port, UINT Delay, double drop);
	~UDPServer();

	void Start();
	void Stop();
	void Print(const string& info, Level lv = NOP);

private:
	UINT port;
	SOCKET serverSocket;
	sockaddr_in serverAddr;
	sockaddr_in clientAddr;
	std::ofstream outFile;
	bool isconnect = false;
	uint32_t ackNum = 0;
	uint32_t currentSeqNum = 0;
	uint32_t lastProcessedSeqNum = 0;
	uint64_t totalBytesRecv = 0;
	UINT Delay;
	double drop;

	string GetCurrTime();
	void receiveData();
	void writeData(const char* data, size_t length, uint32_t seqNum);
	void sendPacket(UDPPacket& packet);
	void sendACK();
	void openFile(const string& filename);
	void closeFile();
	void initializeWinsock();
	void handshake();
	void waveHand();
	bool waitForPacket(uint32_t expectedFlag);
	bool receivePacket(UDPPacket& packet);
	void PrintPacketInfo(const UDPPacket& packet, Level lv);
};
