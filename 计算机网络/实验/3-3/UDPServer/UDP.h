#pragma once

#define WIN32_LEAN_AND_MEAN
#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS

#include <WinSock2.h>
#include <ws2tcpip.h>
#include <iostream>
#include <Windows.h>
#include "UDPPacket.h"

#pragma comment(lib, "ws2_32.lib")

enum Level { INFO, WARN, ERR, RECV, SEND, NOP };

class UDP {
public:
	virtual void handshake() = 0;
	virtual void waveHand() = 0;

	std::string GetCurrTime() const {
		std::string strTime = "";
		time_t now;
		time(&now);  // 获取当前时间
		tm tmNow;
		localtime_s(&tmNow, &now);
		strTime += std::to_string(tmNow.tm_year + 1900) + "-";
		strTime += std::to_string(tmNow.tm_mon + 1) + "-";
		strTime += std::to_string(tmNow.tm_mday) + " ";
		strTime += std::to_string(tmNow.tm_hour) + ":";
		strTime += std::to_string(tmNow.tm_min) + ":";
		strTime += std::to_string(tmNow.tm_sec);
		return strTime;
	}

	// 打印包信息
	void PrintPacketInfo(const UDPPacket& packet, Level lv) const {
		const Header& hdr = packet.getHeader();
		std::string flagStr = packet.flagsToString();
		std::string info = "Packet - SeqNum: " + std::to_string(hdr.seqNum) +
			", AckNum: " + std::to_string(hdr.ackNum) +
			", Checksum: " + std::to_string(hdr.checksum) +
			", Flags: " + flagStr;

		if (packet.isFlagSet(Flag::DATA)) {
			// 如果是数据包，添加数据长度信息
			info += ", Data Length: " + std::to_string(hdr.length);
		}
		Print(info, lv);
	}

	// 打印信息
	void Print(const std::string& info, Level lv = NOP) const {
		HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
		WORD saved_attributes;

		// 保存当前的颜色设置
		CONSOLE_SCREEN_BUFFER_INFO consoleInfo;
		GetConsoleScreenBufferInfo(hConsole, &consoleInfo);
		saved_attributes = consoleInfo.wAttributes;

		std::cout << GetCurrTime() + " ";

		// 设置新的颜色属性
		switch (lv) {
		case Level::INFO:
			SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN);
			std::cout << "[INFO] ";
			break;
		case Level::WARN:
			SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN | FOREGROUND_RED);
			std::cout << "[WARN] ";
			break;
		case Level::ERR:
			SetConsoleTextAttribute(hConsole, FOREGROUND_RED);
			std::cout << "[ERROR] ";
			break;
		case Level::RECV:
			SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN | FOREGROUND_BLUE);
			std::cout << "[RECV] ";
			break;
		case Level::SEND:
			SetConsoleTextAttribute(hConsole, FOREGROUND_BLUE | FOREGROUND_INTENSITY);
			std::cout << "[SEND] ";
			break;
		default:
			SetConsoleTextAttribute(hConsole, saved_attributes); // 使用默认颜色
			break;
		}
		// 恢复原来的颜色设置
		SetConsoleTextAttribute(hConsole, saved_attributes);
		// 输出信息
		std::cout << info << std::endl;
	}
};
