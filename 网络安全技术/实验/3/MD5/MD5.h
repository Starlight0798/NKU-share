#pragma once

#include <vector>
#include <string>
#include <cstdint>

class MD5 {
public:
	MD5();
	~MD5();

	// MD5�ӿ�
	std::string computeMD5(const unsigned char* input, size_t length);
	std::string computeMD5(const std::string& input);

	// ����MD5״̬��׼���µļ���
	void reset();

private:
	// MD5�����任���̣�����һ��64�ֽڿ�
	void transform(const unsigned char block[64]);

	// ���ڸ���״̬�ĺ��������Զ�ε���
	void update(const unsigned char* input, size_t length);
	void update(const std::string& input);

	// ���ժҪ����
	std::vector<unsigned char> finalize();

	// ����ʮ�����Ƹ�ʽ��ժҪ
	std::string toHexString();

	// ����ͽ��뺯�������ڲ����ֽں�32λ��֮���ת��
	static void encode(uint32_t input[], unsigned char output[], size_t len);
	static void decode(const unsigned char input[], uint32_t output[], size_t len);

	// ����MD5����ĸ�������
	static uint32_t F(uint32_t x, uint32_t y, uint32_t z);
	static uint32_t G(uint32_t x, uint32_t y, uint32_t z);
	static uint32_t H(uint32_t x, uint32_t y, uint32_t z);
	static uint32_t I(uint32_t x, uint32_t y, uint32_t z);
	static void FF(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac);
	static void GG(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac);
	static void HH(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac);
	static void II(uint32_t& a, uint32_t b, uint32_t c, uint32_t d, uint32_t x, uint32_t s, uint32_t ac);

	// ѭ������
	static uint32_t rotate_left(uint32_t x, int n);

	// MD5�����ı���
	uint32_t state[4];  // MD5״̬(A, B, C, D)
	uint32_t count[2];  // λ��������
	unsigned char buffer[64]; // �������뻺����
	std::vector<unsigned char> digest; // �洢����ժҪ������
	bool finalized; // ��ʾժҪ�Ƿ��Ѿ�����

	static const unsigned char PADDING[64];  // ����õ�����
};