#include <iostream>
#include <string>
#include <vector>
#include <thread>
#include <mutex>
#include <map>
#include <unistd.h>
#include <iomanip>
#include "../include/utils.h"
#include "../include/Ping.h"
#include "../include/TCPConnectScan.h"
#include "../include/TCPSYNScan.h"
#include "../include/TCPFINScan.h"
#include "../include/UDPScan.h"

std::mutex scanMutex;
std::map<int, bool> scanResults; 
std::string type;
const int BATCH_SIZE = 256;        // 每批处理的端口数量

void printHelp() {
    std::cout << "Scaner: usage: [-h] --help information\n"
              << "               [-p] --Ping test\n"
              << "               [-c] --TCP connect scan\n"
              << "               [-s] --TCP syn scan\n"
              << "               [-f] --TCP fin scan\n"
              << "               [-u] --UDP scan\n";
}

void runScan(const std::string& hostIP, int beginPort, int endPort, 
             bool(*scanFunc)(const std::string&, int)) {
    for (int port = beginPort; port <= endPort; ++port) {
        bool result = scanFunc(hostIP, port);
        std::lock_guard<std::mutex> lock(scanMutex);
        scanResults[port] = result; 
        if (result) {
            std::cout << "Host: " << hostIP << " Port: " << port << " open!\n";
        } else {
            std::cout << "Host: " << hostIP << " Port: " << port << " closed!\n";
        }
    }
}

void printResults() {
    const int portWidth = 6;
    const int statusWidth = 8;
    const int totalWidth = portWidth + statusWidth + 5; 

    std::cout << "\n" << type << " Scan Results:\n";
    std::cout << "+" << std::string(totalWidth - 2, '-') << "+\n";
    std::cout << "| " << std::left << std::setw(portWidth) << "Port"
              << "| " << std::left << std::setw(statusWidth) << "Status " << "|\n";
    std::cout << "+" << std::string(totalWidth - 2, '-') << "+\n";
    for (const auto& entry : scanResults) {
        std::cout << "| " << std::left << std::setw(portWidth) << entry.first
                  << "| " << std::left << std::setw(statusWidth) << (entry.second ? "Open" : "Closed") << "|\n";
    }
    std::cout << "+" << std::string(totalWidth - 2, '-') << "+\n";
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printHelp();
        return 1;
    }

    std::string option = argv[1];
    if (option == "-h") {
        printHelp();
        return 0;
    }

    if (option == "-p") {
        type = "Ping";
        if (argc < 3) {
            std::cerr << "Invalid arguments for Ping. Please provide IP address.\n";
            return 1;
        }
        std::string hostIP = argv[2];
        if (!isValidIP(hostIP)) {
            std::cerr << "Invalid IP address.\n";
            return 1;
        }
        if (!Ping(hostIP)) {
            std::cerr << "Ping to host " << hostIP << " failed. Host is unreachable.\n";
            return 1;
        }
        std::cout << "Ping to host " << hostIP << " successful!\n";
        return 0;
    }

    if (argc < 5) {
        std::cerr << "Invalid arguments. Please provide IP address, begin port, and end port.\n";
        return 1;
    }

    std::string hostIP = argv[2];
    int beginPort = std::stoi(argv[3]);
    int endPort = std::stoi(argv[4]);

    if (!isValidIP(hostIP) || !isValidPort(beginPort) || !isValidPort(endPort)) {
        std::cerr << "Invalid IP address or port range.\n";
        return 1;
    }
    if (!Ping(hostIP)) {
        std::cerr << "Ping to host " << hostIP << " failed. Host is unreachable.\n";
        return 1;
    }

    std::vector<std::thread> threads;

    if (option == "-c") {
        type = "TCP Connect";
        std::cout << "Begin TCP connect scan...\n";
        for (int i = beginPort; i <= endPort; i += BATCH_SIZE) {
            int batchEnd = std::min(i + BATCH_SIZE - 1, endPort);
            threads.emplace_back(runScan, hostIP, i, batchEnd, TCPConnectScan);
        }
    } else if (option == "-s") {
        type = "TCP SYN";
        std::cout << "Begin TCP SYN scan...\n";
        for (int i = beginPort; i <= endPort; i += BATCH_SIZE) {
            int batchEnd = std::min(i + BATCH_SIZE - 1, endPort);
            threads.emplace_back(runScan, hostIP, i, batchEnd, TCPSYNScan);
        }
    } else if (option == "-f") {
        type = "TCP FIN";
        std::cout << "Begin TCP FIN scan...\n";
        for (int i = beginPort; i <= endPort; i += BATCH_SIZE) {
            int batchEnd = std::min(i + BATCH_SIZE - 1, endPort);
            threads.emplace_back(runScan, hostIP, i, batchEnd, TCPFINScan);
        }
    } else if (option == "-u") {
        type = "UDP";
        std::cout << "Begin UDP scan...\n";
        for (int i = beginPort; i <= endPort; i += BATCH_SIZE) {
            int batchEnd = std::min(i + BATCH_SIZE - 1, endPort);
            threads.emplace_back(runScan, hostIP, i, batchEnd, UDPScan);
        }
    } else {
        std::cerr << "Invalid scan option. Use -h for help.\n";
        return 1;
    }

    for (auto& thread : threads) {
        if (thread.joinable()) {
            thread.join();
        }
    }

    printResults(); 

    return 0;
}
