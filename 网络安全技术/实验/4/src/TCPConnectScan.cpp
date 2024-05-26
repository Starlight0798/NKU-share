#include <iostream>
#include <string>
#include <cstring>
#include <cstdlib>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>

bool TCPConnectScan(const std::string& hostIP, int port) {
    int sockfd;
    struct sockaddr_in sa;
    
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        std::cerr << "Error creating socket." << std::endl;
        return false;
    }

    memset(&sa, 0, sizeof(struct sockaddr_in));
    sa.sin_family = AF_INET;
    sa.sin_port = htons(port);
    sa.sin_addr.s_addr = inet_addr(hostIP.c_str());

    if (connect(sockfd, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
        std::cerr << "Port " << port << " closed." << std::endl;
        close(sockfd);
        return false;
    } else {
        std::cout << "Port " << port << " open." << std::endl;
        close(sockfd);
        return true;
    }
}
