#include "UDPServer.h"

// 构造函数
UDPServer::UDPServer(UINT port, UINT Delay, double drop) {
	this->port = port;
	this->Delay = Delay;
	this->drop = drop;
	// 初始化Winsock
	WSADATA wsaData;
	int result = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (result != 0) {
		Print("WSAStartup failed: " + std::to_string(result), ERR);
		exit(1);
	}
}

// 析构函数
UDPServer::~UDPServer() {
	closesocket(serverSocket);
	WSACleanup();
}

// 开始服务器
void UDPServer::Start() {
	serverSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (serverSocket == INVALID_SOCKET) {
		Print("Failed to create socket: " + std::to_string(WSAGetLastError()), ERR);
		WSACleanup();
		exit(1);
	}

	serverAddr.sin_family = AF_INET;
	serverAddr.sin_addr.s_addr = htonl(INADDR_ANY); // 监听任意地址
	serverAddr.sin_port = htons(static_cast<u_short>(port));

	if (bind(serverSocket, (SOCKADDR*)&serverAddr, sizeof(serverAddr)) == SOCKET_ERROR) {
		Print("Bind failed with error: " + std::to_string(WSAGetLastError()), ERR);
		closesocket(serverSocket);
		WSACleanup();
		exit(1);
	}

	Print("Server start at port: " + std::to_string(port), INFO);
#ifdef Lab3_4
	std::cout << "ready" << std::endl;
#endif
	receiveData();
}

// 监听并接收数据
void UDPServer::receiveData() {
	bool receivingFile = false;
	ULONGLONG startTime = 0;
	ULONGLONG endTime = 0;

	while (true) {
		UDPPacket packet;
		if (receivePacket(packet)) {
			const Header& pktHeader = packet.getHeader();

			// 检查是否是文件传输的开始
			if (packet.isFlagSet(Flag::START)) {
				openFile("received_file.bin");
				receivingFile = true;
				totalBytesRecv = 0;                 // 重置接收的总字节数
				exptSeq = pktHeader.seqNum + 1;	    // 重置期望的序列号
				Print("Start receiving file.", INFO);
				startTime = GetTickCount64(); // 记录开始时间
				continue;
			}

			// 如果是数据包，并且已经开始接收文件
			if (packet.isFlagSet(Flag::DATA) && receivingFile) {
				// 检查是否是期望seq
				uint32_t recvSeq = pktHeader.seqNum;
				if (recvSeq > exptSeq) {    // 接收到的包序列号大于期望的序列号，说明有包丢失，重传ACK
					Print("Received out of order packet with seq: " + std::to_string(recvSeq), WARN);
					ackNum = lastack;               // 退回ACK的值
					sendPacket(Flag::ACK, currSeq++, ackNum);   // 重传ACK
					continue;
				}
				else if (recvSeq < exptSeq) {   // 重复接收到的包，回复老的ACK即可
					Print("Received duplicate packet with seq: " + std::to_string(recvSeq), WARN);
					sendPacket(Flag::ACK, currSeq++, recvSeq + 1);   // 回复老的ACK
					continue;
				}
				// 更新期望的序列号
				exptSeq = recvSeq + 1;
				// 写入数据
				writeData(packet.getData(), pktHeader.length);
				totalBytesRecv += pktHeader.length;
				// 发送ACK
				sendPacket(Flag::ACK, currSeq++, ackNum);
			}

			// 检查是否是文件传输的结束
			if (packet.isFlagSet(Flag::END)) {
				endTime = GetTickCount64(); // 记录结束时间
				closeFile();
				receivingFile = false;
				double elapsed = static_cast<double>(endTime - startTime) / 1000.0;
				Print("Bytes Recv: " + std::to_string(totalBytesRecv) + " bytes", INFO);
				Print("Time Taken: " + std::to_string(elapsed) + " seconds", INFO);
				Print("Average Speed: " + std::to_string(totalBytesRecv / elapsed) + " bytes/s", INFO);

#ifdef Lab3_4
				std::cout << std::to_string(elapsed) << std::endl;
				std::cout << std::to_string(totalBytesRecv / elapsed) << std::endl;
				std::cout << "end";
#endif
				continue;
			}

			// 处理握手请求
			if (packet.isFlagSet(Flag::SYN)) {
				handshake();
				continue;
			}

			// 检查是否是挥手请求（FIN）
			if (packet.isFlagSet(Flag::FIN)) {
				waveHand();
				break;
			}
		}
	}
}

// 停止服务器并清理资源
void UDPServer::Stop() {
	// 执行挥手过程
	if (isconnect) waveHand();
	closesocket(serverSocket);
	WSACleanup();
	Print("Server stopped.", INFO);
}

// 写入数据
void UDPServer::writeData(const char* data, uint16_t length) {
	if (!outFile.is_open()) {
		openFile("received_file.bin");  // 指定文件名
	}
	// 写入新的数据包
	outFile.write(data, length);
}

// 发送Packet
void UDPServer::sendPacket(uint32_t flags, uint32_t seq, uint32_t ack, const char* data, uint16_t length) {
	UDPPacket packet;
	packet.setSeq(seq);		// 使用当前序列号
	packet.setFlag(flags);
	if (packet.isFlagSet(Flag::DATA)) {
		packet.setData(data, length);
	}
	if (packet.isFlagSet(Flag::ACK)) {
		packet.setAck(ack);
	}
	packet.setChecksum(packet.calChecksum()); // 计算校验和
	// 打印发送的数据包信息
	PrintPacketInfo(packet, SEND);
	std::string serialized = packet.serialize();
	sendto(serverSocket, serialized.c_str(), serialized.size(), 0,
		(struct sockaddr*)&clientAddr, sizeof(clientAddr));
}

void UDPServer::openFile(const std::string& filename) {
	outFile.open(filename, std::ios::binary | std::ios::out);
	if (!outFile.is_open()) {
		Print("Failed to open file for writing: " + filename, ERR);
		return;
	}
}

void UDPServer::closeFile() {
	if (outFile.is_open()) {
		outFile.close();
		Print("File received and saved.", INFO);
	}
}

void UDPServer::handshake() {
	// 发送握手响应（SYN-ACK）
	sendPacket(Flag::SYN | Flag::ACK, currSeq++, ackNum);

	// 等待确认（ACK）
	if (waitForPacket(Flag::ACK)) {
		isconnect = true;
		Print("Handshake successful.", INFO);
	}
	else {
		Print("Handshake failed.", ERR);
	}
}

void UDPServer::waveHand() {
	// 第一步：发送ACK响应客户端的FIN
	sendPacket(Flag::ACK, currSeq++, ackNum);
	// 第二步：等待一段时间
	Sleep(50);
	// 第三步：发送FIN-ACK包
	sendPacket(Flag::FIN | Flag::ACK, currSeq++, ackNum);
	// 第四步：等待客户端的ACK
	if (waitForPacket(Flag::ACK)) {
		isconnect = false;
		ackNum = 0;
		exptSeq = 0;
		currSeq = 0;
		lastack = 0;
		Print("Wavehand successful.", INFO);
	}
	else {
		Print("No ACK received for FIN.", WARN);
	}
}

// 等待指定的包
bool UDPServer::waitForPacket(uint32_t expectedFlag) {
	UDPPacket packet;
	for (int attempts = 0; attempts < MAX_ATTEMPTS; ++attempts) {
		if (receivePacket(packet)) {
			if (packet.isFlagSet(expectedFlag)) {
				return true;
			}
			break;
		}
	}
	return false;
}

bool UDPServer::receivePacket(UDPPacket& packet) {
	// 模拟丢包和延时处理参数
	static std::default_random_engine generator_drop, generator_delay;
	UINT every;
	if (drop > 0) every = static_cast<UINT>(1 / drop);
	else every = UINT32_MAX;
	std::uniform_int_distribution<int> delayDistribution(0, 10); // 每10个包中随机选择一个进行延时
	std::uniform_int_distribution<int> lossDistribution(0, every); // 每every个包中随机选择一个进行丢包
	static bool drop = false;
	static bool delay = false;

	char* const buffer = new char[BUFFER_SIZE];
	int addrLen = sizeof(clientAddr);
	int recvLen = recvfrom(serverSocket, buffer, BUFFER_SIZE, 0, (struct sockaddr*)&clientAddr, &addrLen);

	if (recvLen > 0) {
		packet.deserialize(std::string(buffer, recvLen));
		Header pktHeader = packet.getHeader();

		// 检查数据包的检验和
		if (!packet.validChecksum()) {
			Print("Checksum failed for packet with seq: " + std::to_string(pktHeader.seqNum), WARN);
			return false;
		}

		// 对数据包模拟丢包和延时
		if (packet.isFlagSet(Flag::DATA)) {
			drop = (lossDistribution(generator_drop) == 0);
			delay = (delayDistribution(generator_delay) == 0);
			// 随机选择Data包进行丢包
			if (drop) {
				Print("Simulating packet loss for packet seq: " + std::to_string(pktHeader.seqNum), WARN);
				return false; // 不处理该包，模拟丢包
			}
			// 随机选择Data包进行延时
			if (delay) {
				Print("Delaying ACK for packet seq: " + std::to_string(pktHeader.seqNum), WARN);
				Sleep(Delay);
			}
		}
		lastack = ackNum;                       // 保存上一次的ACK
		ackNum = pktHeader.seqNum + 1;          // 更新ACK
		// 打印接收到的数据包信息
		PrintPacketInfo(packet, RECV);
		return true;
	}
	else if (recvLen == 0 || WSAGetLastError() != WSAEWOULDBLOCK) {
		Print("recvfrom() failed with error code: " + std::to_string(WSAGetLastError()), ERR);
	}
	delete[] buffer;
	return false;
}