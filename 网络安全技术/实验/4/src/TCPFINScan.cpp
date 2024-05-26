#include <iostream>
#include <string>
#include <cstring>
#include <cstdlib>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netinet/tcp.h>
#include <netinet/ip.h>
#include <errno.h>
#include "../include/utils.h"

struct pseudo_header {
    u_int32_t source_address;
    u_int32_t dest_address;
    u_int8_t placeholder;
    u_int8_t protocol;
    u_int16_t tcp_length;
};

bool TCPFINScan(const std::string& hostIP, int port) {
    int sockfd;
    struct sockaddr_in sa;
    char packet[4096];
    struct ip *iph = (struct ip *) packet;
    struct tcphdr *tcph = (struct tcphdr *) (packet + sizeof(struct ip));
    struct pseudo_header psh;

    if ((sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_TCP)) < 0) {
        std::cerr << "Error creating socket: " << strerror(errno) << std::endl;
        return false;
    }

    int one = 1;
    const int *val = &one;
    if (setsockopt(sockfd, IPPROTO_IP, IP_HDRINCL, val, sizeof(one)) < 0) {
        std::cerr << "Error setting socket options: " << strerror(errno) << std::endl;
        close(sockfd);
        return false;
    }

    memset(packet, 0, 4096);
    iph->ip_hl = 5;
    iph->ip_v = 4;
    iph->ip_tos = 0;
    iph->ip_len = htons(sizeof(struct ip) + sizeof(struct tcphdr));
    iph->ip_id = htonl(54321);
    iph->ip_off = 0;
    iph->ip_ttl = 255;
    iph->ip_p = IPPROTO_TCP;
    iph->ip_sum = 0;
    iph->ip_src.s_addr = inet_addr("127.0.0.1");
    iph->ip_dst.s_addr = inet_addr(hostIP.c_str());

    tcph->th_sport = htons(12345);
    tcph->th_dport = htons(port);
    tcph->th_seq = 0;
    tcph->th_ack = 0;
    tcph->th_off = 5;
    tcph->th_flags = TH_FIN;
    tcph->th_win = htons(32767);
    tcph->th_sum = 0;
    tcph->th_urp = 0;

    psh.source_address = inet_addr("127.0.0.1");
    psh.dest_address = inet_addr(hostIP.c_str());
    psh.placeholder = 0;
    psh.protocol = IPPROTO_TCP;
    psh.tcp_length = htons(sizeof(struct tcphdr));

    char pseudo_packet[sizeof(struct pseudo_header) + sizeof(struct tcphdr)];
    memcpy(pseudo_packet, &psh, sizeof(struct pseudo_header));
    memcpy(pseudo_packet + sizeof(struct pseudo_header), tcph, sizeof(struct tcphdr));

    tcph->th_sum = in_cksum((unsigned short*) pseudo_packet, sizeof(pseudo_packet));
    iph->ip_sum = in_cksum((unsigned short*)iph, sizeof(struct ip));

    memset(&sa, 0, sizeof(struct sockaddr_in));
    sa.sin_family = AF_INET;
    sa.sin_port = htons(port);
    sa.sin_addr.s_addr = inet_addr(hostIP.c_str());

    if (sendto(sockfd, packet, ntohs(iph->ip_len), 0, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
        std::cerr << "Error sending FIN packet: " << strerror(errno) << std::endl;
        close(sockfd);
        return false;
    }

    char recvBuf[4096];
    struct sockaddr_in recv_sa;
    socklen_t recv_sa_len = sizeof(recv_sa);
    struct timeval tv;
    tv.tv_sec = 3;
    tv.tv_usec = 0;
    setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof(tv));

    int recv_len = recvfrom(sockfd, recvBuf, sizeof(recvBuf), 0, (struct sockaddr *)&recv_sa, &recv_sa_len);
    if (recv_len < 0) {
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
    int ip_header_len = recvIph->ip_hl << 2;
    struct tcphdr *recvTcph = (struct tcphdr *) (recvBuf + ip_header_len);

    if (recvTcph->th_flags & TH_RST) {
        std::cout << "Received RST, port " << port << " is closed." << std::endl;
        close(sockfd);
        return false;
    } else {
        std::cout << "No RST received, port " << port << " is open or filtered." << std::endl;
        close(sockfd);
        return true;
    }
}
