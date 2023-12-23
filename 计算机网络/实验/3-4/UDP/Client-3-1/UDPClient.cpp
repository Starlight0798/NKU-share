#include "UDPClient.h"

// 获取当前时间信息
string UDPClient::GetCurrTime() {
	string strTime = "";
	time_t now;
	time(&now);  // 获取当前时间
	tm tmNow;
	localtime_s(&tmNow, &now);
	strTime += to_string(tmNow.tm_year + 1900) + "-";
	strTime += to_string(tmNow.tm_mon + 1) + "-";
	strTime += to_string(tmNow.tm_mday) + " ";
	strTime += to_string(tmNow.tm_hour) + ":";
	strTime += to_string(tmNow.tm_min) + ":";
	strTime += to_string(tmNow.tm_sec);
	return strTime;
}

void UDPClient::Print(const string& Info, Level lv) {
#ifndef Lab3_4
	HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
	WORD saved_attributes;

	// 保存当前的颜色设置
	CONSOLE_SCREEN_BUFFER_INFO consoleInfo;
	GetConsoleScreenBufferInfo(hConsole, &consoleInfo);
	saved_attributes = consoleInfo.wAttributes;

	cout << GetCurrTime() + " ";

	// 设置新的颜色属性
	switch (lv) {
	case Level::INFO:
		SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN);
		cout << "[INFO] ";
		break;
	case Level::WARN:
		SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN | FOREGROUND_RED);
		cout << "[WARN] ";
		break;
	case Level::ERR:
		SetConsoleTextAttribute(hConsole, FOREGROUND_RED);
		cout << "[ERROR] ";
		break;
	case Level::RECV:
		SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN | FOREGROUND_BLUE);
		cout << "[RECV] ";
		break;
	case Level::SEND:
		SetConsoleTextAttribute(hConsole, FOREGROUND_BLUE | FOREGROUND_INTENSITY);
		cout << "[SEND] ";
		break;
	default:
		SetConsoleTextAttribute(hConsole, saved_attributes); // 使用默认颜色
		break;
	}
	// 恢复原来的颜色设置
	SetConsoleTextAttribute(hConsole, saved_attributes);
	// 输出信息
	cout << Info << endl;
#endif
}

// 构造函数
UDPClient::UDPClient(const std::string& serverIP, UINT serverPort)
	: serverIP(serverIP), serverPort(serverPort) {
	initializeWinsock();
	createSocket();
	configureServerAddress();
}

// 析构函数
UDPClient::~UDPClient() {
	closesocket(clientSocket);
	WSACleanup();
}

// 初始化Winsock
void UDPClient::initializeWinsock() {
	WSADATA wsaData;
	int result = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (result != 0) {
		Print("WSAStartup failed: " + to_string(result), ERR);
		exit(1);
	}
}

// 创建Socket
void UDPClient::createSocket() {
	clientSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (clientSocket == INVALID_SOCKET) {
		Print("Failed to create socket: " + to_string(WSAGetLastError()), ERR);
		WSACleanup();
		exit(1);
	}

	// 设置非阻塞模式
	u_long mode = 1; // 1表示非阻塞模式，0表示阻塞模式
	if (ioctlsocket(clientSocket, FIONBIO, &mode) != NO_ERROR) {
		Print("Failed to set socket to non-blocking: " + to_string(WSAGetLastError()), ERR);
		closesocket(clientSocket);
		WSACleanup();
		exit(1);
	}
}

// 配置服务器地址
void UDPClient::configureServerAddress() {
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(serverPort);
	inet_pton(AF_INET, serverIP.c_str(), &serverAddr.sin_addr);
}

// 握手
void UDPClient::handshake() {
	// 发送握手请求（SYN）
	UDPPacket synPacket;
	synPacket.setFlag(Flag::SYN);
	sendPacket(synPacket);

	// 等待握手响应（SYN-ACK）
	if (waitForPacket(Flag::SYN | Flag::ACK)) {
		// 发送确认（ACK）
		sendACK();
		isconnected = true;
		Print("Handshake successful.", INFO);
	}
	else {
		Print("Handshake failed.", ERR);
	}
}

// 挥手
void UDPClient::waveHand() {
	// 第一步：发送挥手请求（FIN）
	UDPPacket finPacket;
	finPacket.setFlag(Flag::FIN);
	sendPacket(finPacket);

	// 第二步：等待挥手确认（ACK）
	if (waitForPacket(Flag::ACK)) {
		// 第三步：等待服务器的挥手请求（FIN）
		if (waitForPacket(Flag::FIN)) {
			// 第四步：发送确认（ACK）
			sendACK();
			isconnected = false;
			ackNum = 0;
			currentSeqNum = 0;
			Print("Wavehand successful.", INFO);
		}
		else {
			Print("Wave hand failed, no FIN received from server.", ERR);
		}
	}
	else {
		Print("Wave hand failed, no ACK received for FIN.", ERR);
	}
}

// 发送Packet
void UDPClient::sendPacket(UDPPacket& packet) {
	packet.setSeq(currentSeqNum++);  // 使用当前序列号
	packet.setChecksum(packet.calChecksum()); // 计算校验和

	string serialized = packet.serialize();
	// 打印发送的数据包信息
	PrintPacketInfo(packet, SEND);

	sendto(clientSocket, serialized.c_str(), serialized.size(), 0, (struct sockaddr*)&serverAddr, sizeof(serverAddr));
}

// 发送ACK
void UDPClient::sendACK() {
	UDPPacket ackPacket;
	ackPacket.setFlag(Flag::ACK);
	ackPacket.setAck(ackNum);
	sendPacket(ackPacket);
}

// 发送文件
void UDPClient::SendFile(const string& filePath) {
	std::ifstream file(filePath, std::ios::binary | std::ios::ate);
	if (!file.is_open()) {
		Print("Failed to open file: " + filePath, ERR);
		return;
	}
	else {
		Print("File opened successfully: " + filePath, INFO);
		file.close();
	}

	handshake();
	if (isconnected) {
		sendFileData(filePath);  // 这里已确保文件存在
		waveHand();
	}
}

// 发送文件数据
void UDPClient::sendFileData(const string& filePath) {
#ifdef Lab3_4
	std::cout << "ready" << std::endl;
#endif
	// 发送 START 包
	UDPPacket stPacket;
	stPacket.setFlag(Flag::START);
	sendPacket(stPacket);

	totalBytesSent = 0; // 重置发送的总字节数
	startTime = std::chrono::steady_clock::now(); // 记录开始时间

	std::ifstream file(filePath, std::ios::binary | std::ios::ate);
	file.seekg(0, std::ios::beg);
	char buffer[DATA_SIZE];
	bool eof = false;

	while (!eof) {
		file.read(buffer, sizeof(buffer));
		std::streamsize bytesRead = file.gcount();
		eof = (bytesRead < sizeof(buffer));

		bool ackReceived = false;
		int attempts = 0;

		while (!ackReceived && attempts < MAX_ATTEMPTS) {
			sendFilePacket(buffer, static_cast<uint16_t>(bytesRead));

			if (waitForPacket(Flag::ACK, currentSeqNum - 1)) {
				ackReceived = true;
			}
			else {
				currentSeqNum--; // 只有在成功接收ACK后才增加序列号
				Print("Timeout, resending packet seq: " + std::to_string(currentSeqNum), WARN);
				attempts++;
			}
		}

		if (!ackReceived) {
			Print("Failed to send packet after " + std::to_string(MAX_ATTEMPTS) + " attempts", ERR);
			currentSeqNum++; // 恢复序列号
			return; // 终止发送
		}
	}

	// 发送 END 包
	UDPPacket endPacket;
	endPacket.setFlag(Flag::END);
	sendPacket(endPacket);
	file.close();

#ifdef Lab3_4
	std::cout << "end";
#endif

	// 打印发送的总字节数和时间
	auto endTime = std::chrono::steady_clock::now();
	std::chrono::duration<double> elapsed = endTime - startTime;
	Print("File: " + filePath, INFO);
	Print("Bytes Sent: " + std::to_string(totalBytesSent) + " bytes", INFO);
	Print("Time Taken: " + std::to_string(elapsed.count()) + " seconds", INFO);
}

// 发送文件数据包
void UDPClient::sendFilePacket(const char* data, uint16_t length) {
	UDPPacket packet;
	packet.setData(data, length);
	packet.setFlag(Flag::DATA);
	sendPacket(packet);
	totalBytesSent += length;
}

// 等待指定的包
bool UDPClient::waitForPacket(uint32_t expectedFlag, uint32_t SeqNum, int timeoutMs) {
	char buffer[BUFFER_SIZE];
	int addrLen = sizeof(serverAddr);
	auto startTime = std::chrono::steady_clock::now();

	while (std::chrono::steady_clock::now() - startTime < std::chrono::milliseconds(timeoutMs)) {
		int recvLen = recvfrom(clientSocket, buffer, BUFFER_SIZE, 0, (struct sockaddr*)&serverAddr, &addrLen);
		if (recvLen > 0) {
			UDPPacket packet;
			packet.deserialize(std::string(buffer, recvLen));

			PrintPacketInfo(packet, RECV);

			// 检查是否是期望的包类型
			bool isExpectedFlag = packet.isFlagSet(expectedFlag);
			bool isExpectedSeqNum = (SeqNum == UINT_MAX) || (packet.getHeader().ackNum == SeqNum + 1);

			if (isExpectedFlag && isExpectedSeqNum) {
				ackNum = packet.getHeader().seqNum + 1; // 更新确认号
				return true;
			}
		}

		std::this_thread::sleep_for(std::chrono::milliseconds(10));
	}
	Print("Timeout, no packet received.", WARN);
	return false;
}

// 打印数据包信息
void UDPClient::PrintPacketInfo(const UDPPacket& packet, Level lv) {
	const Header& hdr = packet.getHeader();
	std::string flagStr = packet.flagsToString();
	std::string info = "Packet - SeqNum: " + to_string(hdr.seqNum) +
		", AckNum: " + to_string(hdr.ackNum) +
		", Checksum: " + to_string(hdr.checksum) +
		", Flags: " + flagStr;

	if (packet.isFlagSet(Flag::DATA)) {
		// 如果是数据包，添加数据长度信息
		info += ", Data Length: " + to_string(hdr.length);
	}
	Print(info, lv);
}