#include "UDPClient.h"

int main() {
	// 服务器的IP地址和端口
	std::string serverIP = "127.0.0.1";     // 或者服务器的实际IP地址
	UINT serverPort = 12720;                // 服务器监听的端口
	uint32_t windowSize;           // 窗口大小

	std::cout << "The server port: " << serverPort << std::endl;
	std::cout << "Enter the Window Size: ";
	std::cin >> windowSize;

	// 创建UDP客户端实例
	UDPClient client(serverIP, serverPort, windowSize);

	try {
		// 获取要发送的文件路径
		std::string filePath;
		while (true) {
			std::cout << "Enter the path of the file to send: ";
			std::cin >> filePath;
			if (filePath == "exit") break;
			client.SendFile(filePath);  // 发送文件
		}
	} catch (const std::exception& e) {
		std::cerr << "Error: " << e.what() << std::endl;
		return 1;
	}
	system("pause");
	return 0;
}