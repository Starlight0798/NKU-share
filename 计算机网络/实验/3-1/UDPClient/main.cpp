#include "UDPClient.h"

int main() {
    // 服务器的IP地址和端口
    string serverIP = "127.0.0.1"; // 或者服务器的实际IP地址
    UINT serverPort;               // 服务器监听的端口
    cout << "Enter the server port: ";
    cin >> serverPort;
    // 创建UDP客户端实例
    UDPClient client(serverIP, serverPort);

    try {
        // 获取要发送的文件路径
        string filePath;
        while (true) {
            cout << "Enter the path of the file to send: ";
            cin >> filePath;
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
