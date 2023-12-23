#include "UDPServer.h"

int main(int argc, char* argv[]) {
#ifndef Lab3_4
	try {
		UINT port = 12720; // 可以根据需要修改端口号
		UINT delay = 50;
		double drop = 0.03;
		UDPServer server(port, delay, drop);
		server.Start(); // 启动服务器
		server.Stop();  // 停止服务器
	} catch (const std::exception& e) {
		std::cerr << "Error: " << e.what() << std::endl;
		return 1;
	}
	system("pause");
#else
	try {
		UINT delay = static_cast<uint32_t>(std::stoul(argv[1]));
		double drop = std::stod(argv[2]);
		UDPServer server(12720, delay, drop);
		server.Start();
		server.Stop();
	} catch (const std::exception& e) {
		std::cerr << "Error: " << e.what() << std::endl;
		return 1;
	}
#endif
	return 0;
}