#include "UDPServer.h"

// 获取当前时间信息
string UDPServer::GetCurrTime() {
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

void UDPServer::Print(const string& Info, Level lv) {
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
}

// 构造函数
UDPServer::UDPServer(UINT port) {
    this->port = port;
    initializeWinsock();
}

// 析构函数
UDPServer::~UDPServer() {
    closesocket(serverSocket);
    WSACleanup();
}

// 初始化Winsock
void UDPServer::initializeWinsock() {
    WSADATA wsaData;
    int result = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if (result != 0) {
        Print("WSAStartup failed: " + to_string(result), ERR);
        exit(1);
    }
}


// 开始服务器
void UDPServer::Start() {
    serverSocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (serverSocket == INVALID_SOCKET) {
        Print("Failed to create socket: " + to_string(WSAGetLastError()), ERR);
        WSACleanup();
        exit(1);
    }

    serverAddr.sin_family = AF_INET;
    serverAddr.sin_addr.s_addr = htonl(INADDR_ANY); // 监听任意地址
    serverAddr.sin_port = htons(static_cast<u_short>(port));

    if (bind(serverSocket, (SOCKADDR*)&serverAddr, sizeof(serverAddr)) == SOCKET_ERROR) {
        Print("Bind failed with error: " + to_string(WSAGetLastError()), ERR);
        closesocket(serverSocket);
        WSACleanup();
        exit(1);
    }

    Print("Server start at port: " + to_string(port), INFO);
    receiveData();
}

// 监听并接收数据
void UDPServer::receiveData() {
    bool receivingFile = false;

    // DATA数据丢包和延时处理参数
    const int fixedDelay = 0; 
    const int drop = 50;
    std::default_random_engine generator;
    std::uniform_int_distribution<int> delayDistribution(0, drop); // 每drop个包中随机选择一个进行延时
    std::uniform_int_distribution<int> lossDistribution(0, drop); // 每drop个包中随机选择一个进行丢包

    while (true) {
        UDPPacket packet;
        if (receivePacket(packet)) {
            const Header& pktHeader = packet.getHeader();

            // 检查数据包的检验和
            if (!packet.validChecksum()) {
                Print("Checksum failed for packet with seq: " + to_string(pktHeader.seqNum), WARN);
                continue;
            }

            // 检查是否是文件传输的开始
            if (packet.isFlagSet(Flag::START)) {
                openFile("received_file.bin");
                receivingFile = true;
                Print("Start receiving file.", INFO);
                continue;
            }

            // 如果是数据包，并且已经开始接收文件
            if (packet.isFlagSet(Flag::DATA) && receivingFile) {
                // 随机选择特定包进行丢包
                if (lossDistribution(generator) == 0) {
                    Print("Simulating packet loss for packet seq: " + to_string(pktHeader.seqNum), WARN);
                    ackNum--; // 丢包
                    continue; // 不处理该包，模拟丢包
                }
                // 随机选择特定包进行延时发送ACK
                if (delayDistribution(generator) == 0) {
                    Print("Delaying ACK for packet seq: " + to_string(pktHeader.seqNum), WARN);
                    std::this_thread::sleep_for(std::chrono::milliseconds(fixedDelay));
                }
                writeData(packet.getData(), pktHeader.length, pktHeader.seqNum);
                sendACK();
            }

            // 检查是否是文件传输的结束
            if (packet.isFlagSet(Flag::END)) {
                closeFile();
                receivingFile = false;
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
                continue;
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


void UDPServer::writeData(const char* data, size_t length, uint32_t seqNum) {
    // 只写入新的数据包
    if (seqNum > lastProcessedSeqNum) {
        if (!outFile.is_open()) {
            openFile("received_file.bin");  // 指定文件名
        }
        outFile.write(data, length);
        lastProcessedSeqNum = seqNum; // 更新处理过的最后一个包的序列号
    }
    else {
        // 如果数据包是重复的，则不写入文件，打印信息
        Print("Received duplicate packet with seq: " + std::to_string(seqNum), WARN);
    }
}



void UDPServer::sendPacket(UDPPacket& packet) {
    packet.setSeq(currentSeqNum++);
    packet.setChecksum(packet.calChecksum());
    std::string serializedPacket = packet.serialize();

    // 打印发送的数据包信息
    PrintPacketInfo(packet, SEND);

    sendto(serverSocket, serializedPacket.c_str(), serializedPacket.size(), 0,
        (struct sockaddr*)&clientAddr, sizeof(clientAddr));
}


void UDPServer::sendACK() {
    UDPPacket ackPacket;
    ackPacket.setFlag(Flag::ACK);
    ackPacket.setAck(ackNum);
    sendPacket(ackPacket);
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
    lastProcessedSeqNum = 0;
}


void UDPServer::handshake() {
    // 发送握手响应（SYN-ACK）
    UDPPacket synAckPacket;
    synAckPacket.setFlag(Flag::SYN | Flag::ACK);
    synAckPacket.setSeq(1); // 设置序列号
    sendPacket(synAckPacket);

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
    sendACK();

    // 第二步：等待一段时间
    Sleep(50);

    // 第三步：发送FIN-ACK包
    UDPPacket finPacket;
    finPacket.setFlag(Flag::FIN | Flag::ACK);
    finPacket.setAck(ackNum);
    sendPacket(finPacket);

    // 第四步：等待客户端的ACK
    if (waitForPacket(Flag::ACK)) {
        isconnect = false;
        ackNum = 0;
        currentSeqNum = 0;
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
    char buffer[BUFFER_SIZE];
    int addrLen = sizeof(clientAddr);
    int recvLen = recvfrom(serverSocket, buffer, BUFFER_SIZE, 0, (struct sockaddr*)&clientAddr, &addrLen);

    if (recvLen > 0) {
        packet.deserialize(string(buffer, recvLen));
        Header pktHeader = packet.getHeader();
        if (packet.isFlagSet(Flag::DATA) && pktHeader.seqNum < ackNum - 1) {
            // 如果收到的数据包的序列号小于当前的确认号，说明该数据包为ACK丢失重传
            Print("Packet with seq: " + to_string(pktHeader.seqNum) + " is already received.", WARN);
            sendACK(); // 重发ACK
        	return false;
        }
        ackNum = packet.getHeader().seqNum + 1;      // 更新最后接收的序列号
        // 打印接收到的数据包信息
        PrintPacketInfo(packet, RECV);
        return true;
    }
    else if (recvLen == 0 || WSAGetLastError() != WSAEWOULDBLOCK) {
        Print("recvfrom() failed with error code: " + to_string(WSAGetLastError()), ERR);
    }

    return false;
}


// 打印数据包信息
void UDPServer::PrintPacketInfo(const UDPPacket& packet, Level lv) {
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