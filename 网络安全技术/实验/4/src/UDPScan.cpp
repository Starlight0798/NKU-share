#include <iostream>
#include <string>
#include <cstring>
#include <cstdlib>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netinet/udp.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <errno.h>
#include "../include/utils.h"

bool UDPScan(const std::string& hostIP, int port) {
    int sockfd;
    struct sockaddr_in sa;
    char packet[4096];
    struct ip *iph = (struct ip *) packet;
    struct udphdr *udph = (struct udphdr *) (packet + sizeof(struct ip));

    if ((sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_UDP)) < 0) {
        std::cerr << "Error creating socket: " << strerror(errno) << std::endl;
        return false;
    }

    memset(packet, 0, 4096);
    iph->ip_hl = 5;
    iph->ip_v = 4;
    iph->ip_tos = 0;
    iph->ip_len = htons(sizeof(struct ip) + sizeof(struct udphdr));
    iph->ip_id = htonl(54321);
    iph->ip_off = 0;
    iph->ip_ttl = 255;
    iph->ip_p = IPPROTO_UDP;
    iph->ip_src.s_addr = inet_addr("127.0.0.1");
    iph->ip_dst.s_addr = inet_addr(hostIP.c_str());
    iph->ip_sum = in_cksum((unsigned short *) packet, sizeof(struct ip));

    udph->uh_sport = htons(12345);
    udph->uh_dport = htons(port);
    udph->uh_ulen = htons(sizeof(struct udphdr));
    udph->uh_sum = 0;

    udph->uh_sum = in_cksum((unsigned short *) udph, sizeof(struct udphdr));

    memset(&sa, 0, sizeof(struct sockaddr_in));
    sa.sin_family = AF_INET;
    sa.sin_port = htons(port);
    sa.sin_addr.s_addr = inet_addr(hostIP.c_str());

    if (sendto(sockfd, packet, ntohs(iph->ip_len), 0, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
        std::cerr << "Error sending UDP packet: " << strerror(errno) << std::endl;
        close(sockfd);
        return false;
    }

    char recvBuf[4096];
    struct timeval tv;
    tv.tv_sec = 3;
    tv.tv_usec = 0;
    setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);

    if (recvfrom(sockfd, recvBuf, sizeof(recvBuf), 0, nullptr, nullptr) < 0) {
        if (errno == EWOULDBLOCK || errno == EAGAIN) {
            std::cout << "No response, port " << port << " is open or filtered." << std::endl;
            close(sockfd);
            return true;
        } else {
            std::cerr << "Error receiving response: " << strerror(errno) << std::endl;
            close(sockfd);
            return false;
        }
    }

    struct ip *recvIph = (struct ip *) recvBuf;
    struct icmphdr *recvIcmph = (struct icmphdr *) (recvBuf + (recvIph->ip_hl << 2));

    if (recvIcmph->type == ICMP_DEST_UNREACH && recvIcmph->code == ICMP_PORT_UNREACH) {
        std::cout << "Received ICMP port unreachable, port " << port << " is closed." << std::endl;
        close(sockfd);
        return false;
    } else {
        std::cout << "Unexpected ICMP response, port " << port << " is filtered." << std::endl;
        close(sockfd);
        return false;
    }
}
