#pragma once

#include <cstdint>
#include <utility>
#include <vector>
#include <string>

struct PublicKey {
	uint64_t n, e;
};

struct PrivateKey {
	uint64_t n, d;
};

class RSA {
public:
	static const int BLOCK_SIZE = 2;
	static void generateKeys(PublicKey& pubkey, PrivateKey& prikey);		// ���ɹ�˽Կ��
	static std::vector<uint8_t> encrypt(const std::vector<uint8_t>& plaintext, PublicKey pubkey);	// ʹ�ù�Կ����
	static std::vector<uint8_t> decrypt(const std::vector<uint8_t>& ciphertext, PrivateKey prikey);	// ʹ��˽Կ����
	static uint64_t encrypt(uint64_t plaintext, PublicKey pubkey);
	static uint64_t decrypt(uint64_t ciphertext, PrivateKey prikey);
	static uint64_t modMul(uint64_t a, uint64_t b, uint64_t mod);
	static uint64_t modPow(uint64_t base, uint64_t exponent, uint64_t mod);
	static uint64_t modInverse(uint64_t a, uint64_t m);					// ��ģ��Ԫ
	static void exgcd(int64_t a, int64_t b, int64_t& x, int64_t& y);		// ��չŷ������㷨
	static uint64_t gcd(uint64_t a, uint64_t b);
	static bool millerRabin(uint64_t n, int iter);	// Miller-Rabin���Բ���
	static uint64_t genPrime(int bits);				// ����һ��������
	static std::vector<uint8_t> strToVec(const std::string& hex_str);
	static std::string vecToStr(const std::vector<uint8_t>& data);
};
