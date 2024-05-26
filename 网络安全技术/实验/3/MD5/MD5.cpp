#include "MD5.h"
#include <cstring>
#include <cmath>

// 填充数组
const unsigned char MD5::PADDING[64] = { 0x80 };

// 构造函数
MD5::MD5() : finalized(false) {
	memset(buffer, 0, sizeof(buffer));
	count[0] = count[1] = 0;
	// 初始化MD5的四个主要数据寄存器
	state[0] = 0x67452301;
	state[1] = 0xEFCDAB89;
	state[2] = 0x98BADCFE;
	state[3] = 0x10325476;
}

// 析构函数
MD5::~MD5() {
	// 清理动作，保证不泄露信息
	memset(buffer, 0, sizeof(buffer));
	memset(count, 0, sizeof(count));
	memset(state, 0, sizeof(state));
	memset(&digest[0], 0, digest.size());
}

// MD5 初始化函数，初始化核心变量
void MD5::reset() {
	finalized = false;
	count[0] = count[1] = 0;
	state[0] = 0x67452301;
	state[1] = 0xEFCDAB89;
	state[2] = 0x98BADCFE;
	state[3] = 0x10325476;
	digest.clear();
}

// 更新MD5，输入是原始的数据和长度
void MD5::update(const unsigned char* input, size_t length) {
	size_t index = count[0] / 8 % 64;
	size_t partLen = 64 - index;
	size_t i = 0;

	// 更新位数计数
	count[0] += (uint32_t)(length << 3);
	if (count[0] < (length << 3))
		count[1]++;
	count[1] += (uint32_t)(length >> 29);

	// 足够填满一个64字节块
	if (length >= partLen) {
		memcpy(&buffer[index], input, partLen);
		transform(buffer);

		for (i = partLen; i + 63 < length; i += 64) {
			transform(&input[i]);
		}
		index = 0;
	}

	// 输入剩余部分
	memcpy(&buffer[index], &input[i], length - i);
}

// 将字符串转换为字节数据并更新MD5状态
void MD5::update(const std::string& input) {
	update(reinterpret_cast<const unsigned char*>(input.data()), input.size());
}

// 计算MD5摘要
std::string MD5::computeMD5(const unsigned char* input, size_t length) {
	reset();  // 重置MD5对象状态
	update(input, length);  // 更新状态
	finalize();  // 完成哈希计算
	return toHexString();  // 返回十六进制字符串
}

// 处理std::string数据
std::string MD5::computeMD5(const std::string& input) {
	reset();  // 重置MD5对象状态
	update(input);  // 更新状态，使用std::string重载的update
	finalize();  // 完成哈希计算
	return toHexString();  // 返回十六进制字符串
}

// 完成MD5计算，返回摘要
std::vector<unsigned char> MD5::finalize() {
	unsigned char bits[8];
	size_t index, padLen;

	if (finalized)
		return digest;

	// 保存位数
	encode(count, bits, 8);

	// 填充到56字节
	index = (uint32_t)((count[0] >> 3) & 0x3f);
	padLen = (index < 56) ? (56 - index) : (120 - index);
	update(PADDING, padLen);

	// 加上位数
	update(bits, 8);

	// 存储状态到摘要
	digest.resize(16);
	encode(state, &digest[0], 16);

	// 清理变量
	memset(buffer, 0, sizeof(buffer));
	memset(count, 0, sizeof(count));
	finalized = true;

	return digest;
}

// 编码函数，将uint32转换为字节
void MD5::encode(uint32_t input[], unsigned char output[], size_t len) {
	for (size_t i = 0, j = 0; j < len; i++, j += 4) {
		output[j] = (unsigned char)(input[i] & 0xff);
		output[j + 1] = (unsigned char)((input[i] >> 8) & 0xff);
		output[j + 2] = (unsigned char)((input[i] >> 16) & 0xff);
		output[j + 3] = (unsigned char)((input[i] >> 24) & 0xff);
	}
}

// 解码函数，将字节转换为uint32
void MD5::decode(const unsigned char input[], uint32_t output[], size_t len) {
	for (size_t i = 0, j = 0; j < len; i++, j += 4)
		output[i] = ((uint32_t)input[j]) | (((uint32_t)input[j + 1]) << 8) |
		(((uint32_t)input[j + 2]) << 16) | (((uint32_t)input[j + 3]) << 24);
}

// MD5的主要变换程序
void MD5::transform(const unsigned char block[64]) {
	uint32_t a = state[0], b = state[1], c = state[2], d = state[3], x[16];
	decode(block, x, 64);

	// Round 1
	FF(a, b, c, d, x[0], 7, 0xd76aa478);
	FF(d, a, b, c, x[1], 12, 0xe8c7b756);
	FF(c, d, a, b, x[2], 17, 0x242070db);
	FF(b, c, d, a, x[3], 22, 0xc1bdceee);
	FF(a, b, c, d, x[4], 7, 0xf57c0faf);
	FF(d, a, b, c, x[5], 12, 0x4787c62a);
	FF(c, d, a, b, x[6], 17, 0xa8304613);
	FF(b, c, d, a, x[7], 22, 0xfd469501);
	FF(a, b, c, d, x[8], 7, 0x698098d8);
	FF(d, a, b, c, x[9], 12, 0x8b44f7af);
	FF(c, d, a, b, x[10], 17, 0xffff5bb1);
	FF(b, c, d, a, x[11], 22, 0x895cd7be);
	FF(a, b, c, d, x[12], 7, 0x6b901122);
	FF(d, a, b, c, x[13], 12, 0xfd987193);
	FF(c, d, a, b, x[14], 17, 0xa679438e);
	FF(b, c, d, a, x[15], 22, 0x49b40821);

	// Round 2
	GG(a, b, c, d, x[1], 5, 0xf61e2562);
	GG(d, a, b, c, x[6], 9, 0xc040b340);
	GG(c, d, a, b, x[11], 14, 0x265e5a51);
	GG(b, c, d, a, x[0], 20, 0xe9b6c7aa);
	GG(a, b, c, d, x[5], 5, 0xd62f105d);
	GG(d, a, b, c, x[10], 9, 0x02441453);
	GG(c, d, a, b, x[15], 14, 0xd8a1e681);
	GG(b, c, d, a, x[4], 20, 0xe7d3fbc8);
	GG(a, b, c, d, x[9], 5, 0x21e1cde6);
	GG(d, a, b, c, x[14], 9, 0xc33707d6);
	GG(c, d, a, b, x[3], 14, 0xf4d50d87);
	GG(b, c, d, a, x[8], 20, 0x455a14ed);
	GG(a, b, c, d, x[13], 5, 0xa9e3e905);
	GG(d, a, b, c, x[2], 9, 0xfcefa3f8);
	GG(c, d, a, b, x[7], 14, 0x676f02d9);
	GG(b, c, d, a, x[12], 20, 0x8d2a4c8a);

	// Round 3
	HH(a, b, c, d, x[5], 4, 0xfffa3942);
	HH(d, a, b, c, x[8], 11, 0x8771f681);
	HH(c, d, a, b, x[11], 16, 0x6d9d6122);
	HH(b, c, d, a, x[14], 23, 0xfde5380c);
	HH(a, b, c, d, x[1], 4, 0xa4beea44);
	HH(d, a, b, c, x[4], 11, 0x4bdecfa9);
	HH(c, d, a, b, x[7], 16, 0xf6bb4b60);
	HH(b, c, d, a, x[10], 23, 0xbebfbc70);
	HH(a, b, c, d, x[13], 4, 0x289b7ec6);
	HH(d, a, b, c, x[0], 11, 0xeaa127fa);
	HH(c, d, a, b, x[3], 16, 0xd4ef3085);
	HH(b, c, d, a, x[6], 23, 0x04881d05);
	HH(a, b, c, d, x[9], 4, 0xd9d4d039);
	HH(d, a, b, c, x[12], 11, 0xe6db99e5);
	HH(c, d, a, b, x[15], 16, 0x1fa27cf8);
	HH(b, c, d, a, x[2], 23, 0xc4ac5665);

	// Round 4
	II(a, b, c, d, x[0], 6, 0xf4292244);
	II(d, a, b, c, x[7], 10, 0x432aff97);
	II(c, d, a, b, x[14], 15, 0xab9423a7);
	II(b, c, d, a, x[5], 21, 0xfc93a039);
	II(a, b, c, d, x[12], 6, 0x655b59c3);
	II(d, a, b, c, x[3], 10, 0x8f0ccc92);
	II(c, d, a, b, x[10], 15, 0xffeff47d);
	II(b, c, d, a, x[1], 21, 0x85845dd1);
	II(a, b, c, d, x[8], 6, 0x6fa87e4f);
	II(d, a, b, c, x[15], 10, 0xfe2ce6e0);
	II(c, d, a, b, x[6], 15, 0xa3014314);
	II(b, c, d, a, x[13], 21, 0x4e0811a1);
	II(a, b, c, d, x[4], 6, 0xf7537e82);
	II(d, a, b, c, x[11], 10, 0xbd3af235);
	II(c, d, a, b, x[2], 15, 0x2ad7d2bb);
	II(b, c, d, a, x[9], 21, 0xeb86d391);

	// 更新状态
	state[0] += a;
	state[1] += b;
	state[2] += c;
	state[3] += d;

	// 清理
	memset(x, 0, sizeof(x));
}

// 十六进制转换
std::string MD5::toHexString() {
	if (!finalized)
		return "";

	char buf[33];
	for (int i = 0; i < 16; i++)
		sprintf(buf + i * 2, "%02x", digest[i]);
	buf[32] = 0;

	return std::string(buf);
}

// MD5辅助函数实现
uint32_t MD5::F(uint32_t x, uint32_t y, uint32_t z) { return (x & y) | (~x & z); }
uint32_t MD5::G(uint32_t x, uint32_t y, uint32_t z) { return (x & z) | (y & ~z); }
uint32_t MD5::H(uint32_t x, uint32_t y, uint32_t z) { return x ^ y ^ z; }
uint32_t MD5::I(uint32_t x, uint32_t y, uint32_t z) { return y ^ (x | ~z); }
uint32_t MD5::rotate_left(uint32_t x, int n) {
	return (x << n) | (x >> (32 - n));
}

void MD5::FF(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac) {
	a += F(b, c, d) + x + ac;
	a = rotate_left(a, s) + b;
}

void MD5::GG(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac) {
	a += G(b, c, d) + x + ac;
	a = rotate_left(a, s) + b;
}

void MD5::HH(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac) {
	a += H(b, c, d) + x + ac;
	a = rotate_left(a, s) + b;
}

void MD5::II(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac) {
	a += I(b, c, d) + x + ac;
	a = rotate_left(a, s) + b;
}