#pragma once

#include <vector>
#include <string>
#include <cstdint>

class MD5 {
public:
	MD5();
	~MD5();

	// MD5接口
	std::string computeMD5(const unsigned char* input, size_t length);
	std::string computeMD5(const std::string& input);

	// 重置MD5状态，准备新的计算
	void reset();

private:
	// MD5基本变换过程，处理一个64字节块
	void transform(const unsigned char block[64]);

	// 用于更新状态的函数，可以多次调用
	void update(const unsigned char* input, size_t length);
	void update(const std::string& input);

	// 完成摘要计算
	std::vector<unsigned char> finalize();

	// 返回十六进制格式的摘要
	std::string toHexString();

	// 编码和解码函数，用于操作字节和32位数之间的转换
	static void encode(uint32_t input[], unsigned char output[], size_t len);
	static void decode(const unsigned char input[], uint32_t output[], size_t len);

	// 用于MD5计算的辅助函数
	static uint32_t F(uint32_t x, uint32_t y, uint32_t z);
	static uint32_t G(uint32_t x, uint32_t y, uint32_t z);
	static uint32_t H(uint32_t x, uint32_t y, uint32_t z);
	static uint32_t I(uint32_t x, uint32_t y, uint32_t z);
	static void FF(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac);
	static void GG(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac);
	static void HH(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac);
	static void II(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac);

	// 循环左移
	static uint32_t rotate_left(uint32_t x, int n);

	// MD5上下文变量
	uint32_t state[4];  // MD5状态(A, B, C, D)
	uint32_t count[2];  // 位数计数器
	unsigned char buffer[64]; // 数据输入缓冲区
	std::vector<unsigned char> digest; // 存储最终摘要的数组
	bool finalized; // 表示摘要是否已经生成

	static const unsigned char PADDING[64];  // 填充用的数组
};