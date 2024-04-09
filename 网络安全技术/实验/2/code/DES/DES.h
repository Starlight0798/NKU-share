#pragma once

#include <vector>
#include <bitset>
#include <cstdint>
#include <string>

class DES {
	static const uint8_t IP[64];							// 第一轮置换
	static const uint8_t FP[64];							// 最后一轮置换
	static const uint8_t E_box[48];							// 拓展运算E盒
	static const uint8_t P_box[32];							// 置换运算P盒
	static const uint8_t S_box[8][4][16];					// 8个S盒
	static const uint8_t PC_1[56];							// PC-1置换
	static const uint8_t PC_2[48];							// 密钥压缩置换表
	static const uint8_t shift[16];							// 每轮左移的位数

public:
	static std::string generateKey();										// 生成随机密钥
	DES(const std::string& key);											// 构造函数，需要64位密钥作为参数
	std::vector<uint8_t> encrypt(const std::vector<uint8_t>& plaintext);	// 加密和解密接口
	std::vector<uint8_t> decrypt(const std::vector<uint8_t>& ciphertext);
	static std::vector<uint8_t> strToVec(const std::string& input) {
		return std::vector<uint8_t>(input.begin(), input.end());
	}
	static std::string vecToStr(const std::vector<uint8_t>& input) {
		return std::string(input.begin(), input.end());
	}

private:
	enum MODE { ENCRYPT, DECRYPT };
	std::bitset<48> subKeys[16];											// 存储生成的16轮子密钥
	std::bitset<64>	execute(const std::bitset<64>& data, int mode);			// 加密/解密
	void genSubKeys(const std::bitset<64>& key);							// 生成16轮子密钥
	std::bitset<32> f(const std::bitset<32>& R, const std::bitset<48>& K);	// f函数
	template<size_t N>
	std::bitset<N> leftRotate(const std::bitset<N>& bits, int shift);		// 循环左移
	template<size_t N>
	uint8_t get(const std::bitset<N>& b, size_t pos) { return b[N - 1 - pos]; }
	template<size_t N>
	void set(std::bitset<N>& b, size_t pos, size_t value) { b[N - 1 - pos] = value; }
	std::vector<uint8_t> pad(const std::vector<uint8_t>& data, size_t blockSize);	// PKCS#7填充
	std::vector<uint8_t> unpad(const std::vector<uint8_t>& data, size_t blockSize);	// PKCS#7去填充
};
