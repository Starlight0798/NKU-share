#pragma once

#include <WinSock2.h>
#include <iostream>
#include <string>
#include <ctime>
#include "../DES/DES.h"
#include "../RSA/RSA.h"
#include <vector>

#pragma comment(lib, "ws2_32.lib")

#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS

using std::string;
using std::cout;
using std::endl;
using std::to_string;
using std::cin;

// 定义客户结构体
struct Client {
	SOCKET sock;						// 套接字
	string username;					// 用户名
	Client(SOCKET sock = INVALID_SOCKET, string username = "$") : sock(sock), username(username) {}
};
	
// 聊天室服务器类
class ChatRoomServer {
public:
	ChatRoomServer(UINT port, UINT client);					// 构造函数
	~ChatRoomServer();  					                // 析构函数
	void Start();   				                        // 启动服务器
	void Stop();    	                                    // 关闭服务器
	void PrintInfo(const string& info);                     // 输出日志

private:
	// 定义服务器相关常量
	UINT MAX_CLIENTS;		                    // 最大客户端数量
	UINT PORT;									// 服务器端口
	constexpr static UINT BUFFER_SIZE = 1024;	// 缓冲区大小

	// 定义服务器相关变量
	SOCKET SockServer = INVALID_SOCKET;			// 服务器套接字
	Client* clients;				            // 客户端数组
	HANDLE* hThreads;				            // 线程句柄，每个客户端均有一个线程来处理
	HANDLE hCommandThread;						// 服务器命令线程句柄
	UINT hpointer = 0;				            // 线程句柄数组的指针
	sockaddr_in addrServer;						// 服务器地址
	bool shouldRun = true;                      // 用于标记服务器是否应继续运行
	DES** des;									// DES加密解密对象数组
	PublicKey pub_key;							// 服务器公钥
	PrivateKey pri_key;							// 服务器私钥

	// 定义服务器相关函数
	void InitWinSock();							// 初始化WinSock
	int find_pos();					            // 查找空闲的客户端存放位置
	UINT Online_Count();						// 获取在线人数
	static DWORD WINAPI ClientHandler(LPVOID pParam);		// 每个客户的线程函数
	void BroadcastMessage(const string& msg);   // 将消息广播给所有客户端
	string GetCurrTime();                       // 获取当前时间
	static DWORD WINAPI ListenForCommand(LPVOID pParam);    // 监听服务器命令
};
