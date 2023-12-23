#include "UDPClient.h"

// 构造函数
UDPClient::UDPClient(const std::string& serverIP, UINT serverPort, uint32_t window_size)
	: serverIP(serverIP), serverPort(serverPort), window_size(window_size) {
	timer_start = 0;
	// 初始化Winsock
	WSADATA wsaData;
	int result = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (result != 0) {
		Print("WSAStartup failed: " + std::to_string(result), ERR);
		exit(1);
	}

	// 创建Socket
	clientSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (clientSocket == INVALID_SOCKET) {
		Print("Failed to create socket: " + std::to_string(WSAGetLastError()), ERR);
		WSACleanup();
		exit(1);
	}

	// 设置非阻塞模式
	u_long mode = 1; // 1表示非阻塞模式，0表示阻塞模式
	if (ioctlsocket(clientSocket, FIONBIO, &mode) != NO_ERROR) {
		Print("Failed to set socket to non-blocking: " + std::to_string(WSAGetLastError()), ERR);
		closesocket(clientSocket);
		WSACleanup();
		exit(1);
	}

	// 配置服务器地址
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(serverPort);
	inet_pton(AF_INET, serverIP.c_str(), &serverAddr.sin_addr);
}

// 析构函数
UDPClient::~UDPClient() {
	closesocket(clientSocket);
	WSACleanup();
}

// 打印信息(带互斥锁)
void UDPClient::Print(const std::string& info, Level lv) {
	std::lock_guard<std::mutex> lock(mtx);
	UDP::Print(info, lv);
}

// 打印包信息(带互斥锁)
void UDPClient::PrintPacketInfo(const UDPPacket& packet, Level lv) {
	std::lock_guard<std::mutex> lock(mtx);
	UDP::PrintPacketInfo(packet, lv);
}

// 打印发送缓冲区
void UDPClient::PrintsendBuffer() {
	if (sendBuffer.empty()) return;
	std::lock_guard<std::mutex> lock(mtx);
	std::string str = "SendBuffer: ";
	for (auto& p : sendBuffer) {
		str += std::to_string(p.packet.getHeader().seqNum);
		if (p.ack) str += "(A)";
		str += " ";
	}
	UDP::Print(str, INFO);
}

// 握手
void UDPClient::handshake() {
	// 发送握手请求（SYN）
	sendPacket(Flag::SYN, nextseq++);

	// 等待握手响应（SYN-ACK）
	if (waitForPacket(Flag::SYN | Flag::ACK)) {
		// 发送确认（ACK）
		sendPacket(Flag::ACK, nextseq++, ackNum);
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
	sendPacket(Flag::FIN, nextseq++);

	// 第二步：等待挥手确认（ACK）
	if (waitForPacket(Flag::ACK)) {
		// 第三步：等待服务器的挥手请求（FIN）
		if (waitForPacket(Flag::FIN)) {
			// 第四步：发送确认（ACK）
			sendPacket(Flag::ACK, nextseq++, ackNum);
			isconnected = false;
			ackNum = 0;
			nextseq = 0;
			base = 0;
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
void UDPClient::sendPacket(uint32_t flags, uint32_t seq, uint32_t ack, const char* data, uint16_t length, bool resend) {
	UDPPacket packet;
	packet.setSeq(seq);		// 使用当前序列号
	packet.setFlag(flags);
	if (packet.isFlagSet(Flag::DATA)) {
		packet.setData(data, length);
		// 如果不是重发包则添加到发送缓冲区
		if (!resend) {
			std::lock_guard<std::mutex> lock(mtx);
			sendBuffer.push_back({ packet, false });
			totalBytesSent += length;
		}
	}
	if (packet.isFlagSet(Flag::ACK)) {
		packet.setAck(ack);
	}
	packet.setChecksum(packet.calChecksum()); // 计算校验和

	// 打印发送的数据包信息
	PrintPacketInfo(packet, SEND);

	// 如果发送数据包，打印sendBuffer的信息
	if (packet.isFlagSet(Flag::DATA)) PrintsendBuffer();

	// 序列化发送数据包
	std::string serialized = packet.serialize();
	sendto(clientSocket, serialized.c_str(), serialized.size(), 0,
		(struct sockaddr*)&serverAddr, sizeof(serverAddr));
}

// 发送文件
void UDPClient::SendFile(const std::string& filePath) {
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
void UDPClient::sendFileData(const std::string& filePath) {
	// 发送 START 包
	sendPacket(Flag::START, nextseq++);

	totalBytesSent = 0; // 重置发送的总字节数
	ULONGLONG startTime = GetTickCount64(); // 记录开始时间(区别于timer_start)

	std::ifstream file(filePath, std::ios::binary | std::ios::ate);
	file.seekg(0, std::ios::beg);
	char* const buffer = new char[DATA_SIZE];
	bool eof = false;
	running = true;
	base = nextseq;		//让base指向第一个发送的数据包
	HANDLE hrecv = CreateThread(NULL, 0, receiveAck, this, 0, NULL);	// 创建接收ACK线程

	while (true) {
		// 读取文件并发送包
		while (nextseq < base + window_size && !eof) {
			file.read(buffer, DATA_SIZE);
			std::streamsize bytesRead = file.gcount();
			eof = (bytesRead < DATA_SIZE);

			if (base == nextseq) {
				// 如果这是窗口中的第一个包，则重置定时器
				std::lock_guard<std::mutex> lock(mtx);
				timer_start = GetTickCount64();
			}
			sendPacket(Flag::DATA, nextseq++, 0, buffer, static_cast<uint16_t>(bytesRead));
			if (eof) {
				Print("EOF reached.", INFO);
			}
		}

		// 当发送缓冲区为空时结束
		if (sendBuffer.empty()) break;

		// 超时重传逻辑
		if (GetTickCount64() - timer_start > timeoutMs && !sendBuffer.empty()) {
			// 打印出base和sendbuffer内容
			Print("Timeout, resend the First Packet in the Window! Current base: " + std::to_string(base), WARN);
			// 从缓冲区中获取当前base的包并重传(选择重传)
			UDPPacket packet = sendBuffer[0].packet;
			Header pHead = packet.getHeader();
			sendPacket(pHead.flags, pHead.seqNum, 0, packet.getData(), pHead.length, true);
			timer_start = GetTickCount64();		// 重置定时器
		}
	}

	// 关闭接收线程
	{
		std::lock_guard<std::mutex> lock(mtx);
		running = false;
	}
	if (hrecv) CloseHandle(hrecv);

	// 发送 END 包
	sendPacket(Flag::END, nextseq++);
	file.close();
	delete[] buffer;

	// 打印发送的总字节数和时间
	ULONGLONG endTime = GetTickCount64();
	double elapsed = static_cast<double>(endTime - startTime) / 1000.0;
	Print("File: " + filePath, INFO);
	Print("Bytes Sent: " + std::to_string(totalBytesSent) + " bytes", INFO);
	Print("Time Taken: " + std::to_string(elapsed) + " seconds", INFO);
	Print("Average Speed: " + std::to_string(totalBytesSent / elapsed) + " bytes/s", INFO);
}

// 接收ACK线程
DWORD WINAPI UDPClient::receiveAck(LPVOID pParam) {
	UDPClient* client = (UDPClient*)pParam;
	char* const buffer = new char[BUFFER_SIZE];
	int addrLen = sizeof(client->serverAddr);

	while (client->running) {
		int recvLen = recvfrom(client->clientSocket, buffer, BUFFER_SIZE, 0, (struct sockaddr*)&client->serverAddr, &addrLen);
		if (recvLen > 0) {
			UDPPacket packet;
			packet.deserialize(std::string(buffer, recvLen));
			client->PrintPacketInfo(packet, RECV);

			// 检查校验和
			if (!packet.validChecksum()) {
				client->Print("Checksum failed for packet with seq: " + std::to_string(packet.getHeader().seqNum), WARN);
				continue;
			}

			// 如果是ACK包
			if (packet.isFlagSet(Flag::ACK)) {
				uint32_t ack = packet.getHeader().ackNum;

				// 如果是重复的ACK，不做处理
				if (ack <= client->base) {
					client->Print("Received duplicate ACK with ack: " + std::to_string(ack)
						+ " Current base: " + std::to_string(client->base), WARN);
					continue;
				}

				{
					std::lock_guard<std::mutex> lock(client->mtx);  // 锁定互斥锁
					client->ackNum = packet.getHeader().seqNum + 1; // 更新确认号
					client->timer_start = GetTickCount64();	// 重置定时器

					// 选择确认(SR)机制
					// 记录对应的包收到ACK
					client->sendBuffer[ack - client->base - 1].ack = true;
				}

				// 如果是base对应的ACK，滑动窗口
				if (ack == client->base + 1) {
					std::lock_guard<std::mutex> lock(client->mtx);
					// 因为记录了ACK，所以可能不止滑动一个
					while (!client->sendBuffer.empty() && client->sendBuffer[0].ack) {
						client->sendBuffer.erase(client->sendBuffer.begin());	// 从缓冲区中删除已确认的包
						client->base++;				// 更新窗口基序号
					}
				}
				else client->PrintsendBuffer();
			}
		}
		Sleep(10);
	}
	client->Print("File is not sending, RecvThread close.", INFO);
	delete[] buffer;
	return 0;
}

// 等待指定的包
bool UDPClient::waitForPacket(uint32_t expectedFlag) {
	char* buffer = new char[BUFFER_SIZE];
	int addrLen = sizeof(serverAddr);
	ULONGLONG startTime = GetTickCount64();

	while (GetTickCount64() - startTime < timeoutMs) {
		int recvLen = recvfrom(clientSocket, buffer, BUFFER_SIZE, 0, (struct sockaddr*)&serverAddr, &addrLen);
		if (recvLen > 0) {
			UDPPacket packet;
			packet.deserialize(std::string(buffer, recvLen));
			PrintPacketInfo(packet, RECV);

			if (!packet.validChecksum()) {
				Print("Checksum failed for packet with seq: " + std::to_string(packet.getHeader().seqNum), WARN);
				return false;
			}

			// 检查是否是期望的包类型
			bool isExpectedFlag = packet.isFlagSet(expectedFlag);
			if (isExpectedFlag) {
				ackNum = packet.getHeader().seqNum + 1; // 更新确认号
				return true;
			}
		}
		Sleep(10);
	}
	Print("Timeout, no packet received.", WARN);
	delete[] buffer;
	return false;
}