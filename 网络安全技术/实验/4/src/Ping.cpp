#include "../include/Ping.h"
#include "../include/utils.h"
#include <iostream>
#include <cstring>
#include <sys/socket.h>
#include <netinet/ip_icmp.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <netdb.h>
#include <errno.h>

struct icmp_hdr {
    uint8_t type;
    uint8_t code;
    uint16_t checksum;
    uint16_t id;
    uint16_t sequence;
};

bool Ping(const std::string& hostIP) {
    int sockfd;
    struct sockaddr_in addr;
    struct hostent *host;

    if ((host = gethostbyname(hostIP.c_str())) == nullptr) {
        std::cerr << "Error resolving hostname: " << hstrerror(h_errno) << std::endl;
        return false;
    }

    addr.sin_family = AF_INET;
    addr.sin_port = 0;
    addr.sin_addr.s_addr = *(long*)host->h_addr;

    if ((sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP)) < 0) {
        std::cerr << "Socket creation failed: " << strerror(errno) << std::endl;
        return false;
    }

    int ttl = 64;
    if (setsockopt(sockfd, SOL_IP, IP_TTL, &ttl, sizeof(ttl)) != 0) {
        std::cerr << "Set socket options failed: " << strerror(errno) << std::endl;
        close(sockfd);
        return false;
    }

    struct timeval timeout;
    timeout.tv_sec = 1;
    timeout.tv_usec = 0;
    if (setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) != 0) {
        std::cerr << "Set receive timeout failed: " << strerror(errno) << std::endl;
        close(sockfd);
        return false;
    }

    char sendbuf[64];
    memset(sendbuf, 0, sizeof(sendbuf));
    struct icmp_hdr *icmp = (struct icmp_hdr*)sendbuf;
    icmp->type = ICMP_ECHO;
    icmp->code = 0;
    icmp->id = getpid();
    icmp->sequence = 0;
    icmp->checksum = in_cksum((unsigned short*)icmp, sizeof(sendbuf));

    if (sendto(sockfd, sendbuf, sizeof(sendbuf), 0, (struct sockaddr*)&addr, sizeof(addr)) <= 0) {
        std::cerr << "Send ICMP packet failed: " << strerror(errno) << std::endl;
        close(sockfd);
        return false;
    }

    char recvbuf[1024];
    struct sockaddr_in recv_addr;
    socklen_t addr_len = sizeof(recv_addr);
    while (true) {
        if (recvfrom(sockfd, recvbuf, sizeof(recvbuf), 0, (struct sockaddr*)&recv_addr, &addr_len) <= 0) {
            std::cerr << "Receive ICMP response failed: " << strerror(errno) << std::endl;
            close(sockfd);
            return false;
        }

        struct ip *ip_header = (struct ip*)recvbuf;
        int ip_header_len = ip_header->ip_hl << 2;
        icmp = (struct icmp_hdr*)(recvbuf + ip_header_len);

        if (icmp->type == ICMP_ECHOREPLY && icmp->id == getpid()) {
            if (recv_addr.sin_addr.s_addr == addr.sin_addr.s_addr) {
                std::cout << "Ping successful!" << std::endl;
                close(sockfd);
                return true;
            }
        }
    }

    close(sockfd);
    return false;
}
