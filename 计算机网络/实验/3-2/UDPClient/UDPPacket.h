#pragma once
#include <cstdint>
#include <cstring>
#include <string>

#define DATA_SIZE 10000

struct Flag {
    static constexpr uint16_t START = 0x1;
    static constexpr uint16_t END = (0x1 << 1);
    static constexpr uint16_t DATA = (0x1 << 2);
    static constexpr uint16_t ACK = (0x1 << 3);
    static constexpr uint16_t SYN = (0x1 << 4);
    static constexpr uint16_t FIN = (0x1 << 5);
};

struct Header {
    uint32_t seqNum;   // 序列号
    uint32_t ackNum;   // 确认号
    uint16_t length;   // 数据长度
    uint16_t checksum; // 校验和
    uint16_t flags;    // 标志位
};

class UDPPacket {
private:
    Header header;
    char data[DATA_SIZE];  // 数据大小可以根据需求调整

public:

    UDPPacket() {
        std::memset(&header, 0, sizeof(header));
        std::memset(data, 0, sizeof(data));
    }

    void setFlag(uint16_t flag) {
        header.flags |= flag;
    }

    void setAck(uint32_t ackNum) {
        header.ackNum = ackNum;
    }

    void setSeq(uint32_t seqNum) {
        header.seqNum = seqNum;
    }

    void setLength(uint16_t length) {
        header.length = length;
    }

    void setChecksum(uint16_t checksum) {
        header.checksum = checksum;
    }

    bool isFlagSet(uint16_t flag) const {
        return (header.flags & flag) != 0;
    }

    std::string flagsToString() const {
        std::string flagStr;
        if (header.flags & Flag::ACK) flagStr += "ACK ";
        if (header.flags & Flag::SYN) flagStr += "SYN ";
        if (header.flags & Flag::FIN) flagStr += "FIN ";
        if (header.flags & Flag::DATA) flagStr += "DATA ";
        if (header.flags & Flag::START) flagStr += "START ";
        if (header.flags & Flag::END) flagStr += "END ";

        if (flagStr.empty()) {
            return "None";
        }

        flagStr.pop_back();
        return flagStr;
    }


    // 序列化和反序列化
    std::string serialize() const {
        Header netHeader = header;
        // 序列化之前，转换为网络字节顺序
        netHeader.seqNum = htonl(netHeader.seqNum);
        netHeader.ackNum = htonl(netHeader.ackNum);
        netHeader.length = htons(netHeader.length);

        std::string serialized;
        serialized.append(reinterpret_cast<const char*>(&netHeader), sizeof(netHeader));
        serialized.append(data, ntohs(netHeader.length));
        return serialized;
    }

    void deserialize(const std::string& serialized) {
        std::memcpy(&header, serialized.data(), sizeof(header));
        header.seqNum = ntohl(header.seqNum);
        header.ackNum = ntohl(header.ackNum);
        header.length = ntohs(header.length);

        if (header.length <= DATA_SIZE) {
            std::memcpy(data, serialized.data() + sizeof(header), header.length);
        }
    }

    // 数据处理
    void setData(const char* buffer, uint16_t len) {
        if (buffer != nullptr || len > 0) {
            std::memcpy(data, buffer, len);
            header.length = len;
        }
    }

    const Header& getHeader() const {
        return header;
    }

    const char* getData() const {
        return data;
    }

    // 计算检验和
    uint16_t calChecksum() const {
        uint32_t sum = 0;
        UDPPacket tempPacket = *this;
        tempPacket.header.checksum = 0;  // 将checksum字段设置为0

        const uint8_t* bytes = reinterpret_cast<const uint8_t*>(&tempPacket.header);

        // 确保转换为网络字节序
        Header netHeader = tempPacket.header;
        netHeader.seqNum = htonl(netHeader.seqNum);
        netHeader.ackNum = htonl(netHeader.ackNum);
        netHeader.length = htons(netHeader.length);
        netHeader.checksum = htons(netHeader.checksum);  // 这个字段已经是0，转换不影响
        netHeader.flags = htons(netHeader.flags);

        // 计算头部的校验和
        for (size_t i = 0; i < sizeof(Header); i += 2) {
            uint16_t word = bytes[i] << 8;
            if (i + 1 < sizeof(Header)) {
                word += bytes[i + 1];
            }
            sum += word;
            if (sum >> 16) {
                sum = (sum & 0xFFFF) + (sum >> 16);
            }
        }

        // 计算数据部分的校验和
        bytes = reinterpret_cast<const uint8_t*>(tempPacket.data);
        for (size_t i = 0; i < ntohs(netHeader.length); i += 2) {
            uint16_t word = bytes[i] << 8;
            if (i + 1 < ntohs(netHeader.length)) {
                word += bytes[i + 1];
            }
            sum += word;
            if (sum >> 16) {
                sum = (sum & 0xFFFF) + (sum >> 16);
            }
        }

        return ~sum;
    }

    // 检查校验和是否正确
    bool validChecksum() const {
        // 先计算当前的校验和
        uint16_t computedChecksum = calChecksum();

        // 直接比较计算出的校验和和接收到的校验和
        return header.checksum == computedChecksum;
    }
};
