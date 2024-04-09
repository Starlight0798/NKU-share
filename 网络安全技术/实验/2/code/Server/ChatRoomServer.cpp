#include "ChatRoomServer.h"

// 构造函数
ChatRoomServer::ChatRoomServer(UINT port, UINT client) {
	// 初始化服务器相关常量
	PORT = port;
	MAX_CLIENTS = client;

	// 初始化DES加密解密对象，注意是数组因为每个客户的DES密钥不同
	des = new DES * [MAX_CLIENTS];

	// 服务器生成RSA密钥对
	RSA::generateKeys(this->pub_key, this->pri_key);
	PrintInfo("服务器已生成RSA密钥对.");
	PrintInfo("公钥: (" + to_string(pub_key.n) + ", " + to_string(pub_key.e) + ")");
	PrintInfo("私钥: (" + to_string(pri_key.n) + ", " + to_string(pri_key.d) + ")");

	// 初始化客户端数组和线程句柄数组
	clients = new Client[MAX_CLIENTS];
	hThreads = new HANDLE[MAX_CLIENTS];
	for (UINT i = 0; i < MAX_CLIENTS; i++) {
		clients[i].sock = INVALID_SOCKET;
		hThreads[i] = NULL;
	}

	// 初始化WinSock
	InitWinSock();
}

// 析构函数
ChatRoomServer::~ChatRoomServer() {
	delete[] clients;
	delete[] hThreads;
	for (UINT i = 0; i < MAX_CLIENTS; i++) {
		if (des[i] != nullptr) delete des[i];
	}
	delete[] des;
}

// 初始化WinSock
void ChatRoomServer::InitWinSock() {
	WSADATA wsaData;
	WORD wVersionRequested = MAKEWORD(2, 2);
	int err = WSAStartup(wVersionRequested, &wsaData);
	if (err != 0) {
		cout << "初始化Winsock失败." << err << endl;
		exit(1);
	}
}

// 获取当前时间信息
string ChatRoomServer::GetCurrTime() {
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

// 打印信息，附加当前时间
void ChatRoomServer::PrintInfo(const string& info) {
	cout << GetCurrTime() << " " << info << endl;
}

// 查找空闲的客户端信息&线程存放位置
int ChatRoomServer::find_pos() {
	for (UINT i = 0; i < MAX_CLIENTS; i++) {
		if (clients[i].sock == INVALID_SOCKET) return i;
	}
	return -1;
}

// 获取在线人数
UINT ChatRoomServer::Online_Count() {
	UINT count = 0;
	for (UINT i = 0; i < MAX_CLIENTS; i++) {
		if (clients[i].sock != INVALID_SOCKET) count++;
	}
	return count;
}

// 服务器的主循环
void ChatRoomServer::Start() {
	// 创建套接字
	SockServer = socket(AF_INET, SOCK_STREAM, 0);
	if (SockServer == INVALID_SOCKET) {
		PrintInfo("创建套接字错误.");
		return;
	}

	// 设置服务器地址
	addrServer.sin_family = AF_INET;
	addrServer.sin_port = htons(PORT);
	addrServer.sin_addr.S_un.S_addr = htonl(INADDR_ANY);

	// 绑定套接字
	if (bind(SockServer, (SOCKADDR*)&addrServer, sizeof(addrServer)) == SOCKET_ERROR) {
		PrintInfo("连接错误.");
		return;
	}

	// 监听端口
	if (listen(SockServer, MAX_CLIENTS) == SOCKET_ERROR) {
		PrintInfo("监听错误.");
		return;
	}

	{
		// 显示服务器端口信息
		string msg = "服务器已启动，正在监听端口 " + to_string(PORT) + ".";
		PrintInfo(msg);
	}

	// 创建线程来监听服务端命令
	hCommandThread = CreateThread(NULL, 0, ListenForCommand, this, 0, NULL);

	// 主循环，等待客户端连接
	while (shouldRun) {
		int addr_len = sizeof(addrServer);
		SOCKET clientSocket = accept(SockServer, (SOCKADDR*)&addrServer, &addr_len);
		if (clientSocket != INVALID_SOCKET) {
			// 创建新客户端及相应消息线程
			int pos = find_pos();
			// 容量已满
			if (pos == -1) {
				PrintInfo("客户端数量已达上限，拒绝连接.");
				closesocket(clientSocket);
				continue;
			}
			// 传递指针，方便线程函数获取对应客户端
			hpointer = pos;

			clients[pos].sock = clientSocket;
			// 创建线程来处理客户端消息
			hThreads[pos] = CreateThread(NULL, 0,
				ClientHandler, this, 0, NULL);
		}
	}
}

// 每个客户的线程函数
DWORD WINAPI ChatRoomServer::ClientHandler(LPVOID pParam) {
	ChatRoomServer* pThis = reinterpret_cast<ChatRoomServer*>(pParam);
	std::vector<uint8_t> buffer(BUFFER_SIZE);
	int bytes;

	// 获取当前客户端
	UINT num = pThis->hpointer;
	Client* client = &pThis->clients[num];

	// 发送RSA公钥
	std::vector<uint8_t> pubkey(2 * sizeof(uint64_t));
	*reinterpret_cast<uint64_t*>(pubkey.data()) = pThis->pub_key.n;
	*reinterpret_cast<uint64_t*>(pubkey.data() + sizeof(uint64_t)) = pThis->pub_key.e;
	send(client->sock, reinterpret_cast<const char*>(pubkey.data()), pubkey.size(), 0);
	pThis->PrintInfo("已向客户[" + std::to_string(num) + "]发送RSA公钥.");

	// 接收客户端的DES密钥并用RSA私钥解密
	buffer.clear();
	buffer.resize(BUFFER_SIZE);
	bytes = recv(client->sock, reinterpret_cast<char*>(buffer.data()), BUFFER_SIZE, 0);
	if (bytes <= 0) {
		pThis->PrintInfo("客户端异常断开.");
		closesocket(client->sock);
		return 0;
	}
	buffer.resize(bytes);
	std::vector<uint8_t> decKey = RSA::decrypt(buffer, pThis->pri_key);
	std::string des_key = RSA::vecToStr(decKey);
	pThis->des[num] = new DES(des_key);
	DES* des = pThis->des[num];
	pThis->PrintInfo("已接收客户端[" + std::to_string(num) + "]DES密钥: " + des_key);

	// 读取客户端的用户名
	buffer.clear();
	buffer.resize(BUFFER_SIZE);
	bytes = recv(client->sock, reinterpret_cast<char*>(buffer.data()), BUFFER_SIZE, 0);
	if (bytes <= 0) {
		pThis->PrintInfo("客户端[" + std::to_string(num) + "]异常断开.");
		closesocket(client->sock);
		return 0;
	}
	// 使用 std::vector<uint8_t> 截取实际接收的数据长度
	buffer.resize(bytes);

	// 解密
	client->username = DES::vecToStr(des->decrypt(buffer));

	// 发送欢迎消息
	string welcomeMsg = "欢迎 " + client->username + " 加入聊天室!";
	pThis->PrintInfo(client->username + " 加入聊天室.");
	pThis->BroadcastMessage("系统消息:" + welcomeMsg);

	// 循环接收客户端消息
	while (true) {
		buffer.clear();
		buffer.resize(BUFFER_SIZE);
		// 接收客户端信息，无需用户名
		bytes = recv(client->sock, reinterpret_cast<char*>(buffer.data()), pThis->BUFFER_SIZE, 0);
		// 解密
		buffer.resize(bytes);
		string decmsg = DES::vecToStr(des->decrypt(buffer));

		// 客户端发送退出消息或异常断开连接
		if (bytes <= 0 || decmsg == "exit") {
			// 广播客户端退出消息
			string exitMsg = client->username + " 已退出聊天室." + "(当前在线人数: " + to_string(pThis->Online_Count() - 1) + ")";
			pThis->PrintInfo(exitMsg);
			pThis->BroadcastMessage("系统消息:" + exitMsg);

			// 客户端断开连接
			closesocket(client->sock);
			client->sock = INVALID_SOCKET;
			break;
		}

		// 正常广播消息 约定消息格式为 "用户名:消息内容"
		string message = client->username + ":" + decmsg;
		pThis->PrintInfo("正在广播来自 " + client->username + " 的消息: " + decmsg);
		pThis->BroadcastMessage(message);
	}
	return 0;
}

// 广播消息给所有客户端
void ChatRoomServer::BroadcastMessage(const string& msg) {
	for (UINT i = 0; i <= hpointer; i++) {
		// 将string转换为vector<uint8_t>加密
		std::vector<uint8_t> encmsg = des[i]->encrypt(DES::strToVec(msg));
		if (clients[i].sock != INVALID_SOCKET) {
			// 发送数据
			send(clients[i].sock, reinterpret_cast<const char*>(encmsg.data()), encmsg.size(), 0);
		}
	}
}

// 清理资源, 关闭线程和套接字
void ChatRoomServer::Stop() {
	if (hCommandThread != NULL) TerminateThread(hCommandThread, 0);
	for (UINT i = 0; i < MAX_CLIENTS; i++) {
		if (hThreads[i] != NULL) TerminateThread(hThreads[i], 0);
		if (clients[i].sock != INVALID_SOCKET) {
			closesocket(clients[i].sock);
			clients[i].sock = INVALID_SOCKET;
		}
	}
	if (SockServer != INVALID_SOCKET) {
		closesocket(SockServer);
		SockServer = INVALID_SOCKET;
	}
	WSACleanup();
	PrintInfo("服务器已关闭.");
}

// 监听服务器命令
DWORD WINAPI ChatRoomServer::ListenForCommand(LPVOID pParam) {
	ChatRoomServer* pThis = reinterpret_cast<ChatRoomServer*>(pParam);
	string input;
	while (true) {
		std::getline(cin, input);
		if (input == "exit") {
			pThis->PrintInfo("正在关闭服务器...");
			pThis->shouldRun = false;           // 标记服务器不应继续运行
			closesocket(pThis->SockServer);     // 关闭服务器套接字以使accept返回
			break;
		}
		else if (input == "count") {
			pThis->PrintInfo("当前在线人数: " + to_string(pThis->Online_Count()));
		}
		else {
			pThis->PrintInfo("未知命令.");
		}
	}
	return 0;
}

int main() {
	ChatRoomServer server(12720, 50);  // 选择端口和客户数量和
	try {
		server.Start();
	}
	catch (const std::exception& e) {
		server.PrintInfo("服务器内部异常: " + std::string(e.what()));  // 处理异常
	}
	server.Stop();
	system("pause");
	return 0;
}