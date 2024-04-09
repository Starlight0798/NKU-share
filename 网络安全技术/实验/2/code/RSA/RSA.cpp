#include "pch.h"
#include "RSA.h"
#include "framework.h"
#include <random>
#include <cstdlib>

void RSA::generateKeys(PublicKey& pubkey, PrivateKey& prikey) {
	uint64_t p = RSA::genPrime(16);
	uint64_t q = RSA::genPrime(16);
	uint64_t n = p * q;
	pubkey.n = prikey.n = n;
	uint64_t phi = (p - 1) * (q - 1);
	uint64_t e = 65537;
	while (RSA::gcd(e, phi) != 1) e += 2;
	pubkey.e = e;
	prikey.d = RSA::modInverse(e, phi);
}

std::vector<uint8_t> RSA::encrypt(const std::vector<uint8_t>& plaintext, PublicKey pubkey) {
	std::vector<uint8_t> ciphertext;
	uint64_t block = 0;
	int byte_count = 0;

	for (size_t i = 0; i < plaintext.size(); i++) {
		block = (block << 8) | plaintext[i];
		byte_count++;

		if (byte_count == RSA::BLOCK_SIZE || i == plaintext.size() - 1) {
			uint64_t cipher = RSA::modPow(block, pubkey.e, pubkey.n);
			for (int j = 7; j >= 0; j--) {
				ciphertext.push_back((cipher >> (j * 8)) & 0xff);
			}
			block = 0;
			byte_count = 0;
		}
	}

	return ciphertext;
}

std::vector<uint8_t> RSA::decrypt(const std::vector<uint8_t>& ciphertext, PrivateKey prikey) {
	std::vector<uint8_t> plaintext;
	uint64_t block = 0;
	int byte_count = 0;

	for (size_t i = 0; i < ciphertext.size(); i++) {
		block = (block << 8) | ciphertext[i];
		byte_count++;

		if (byte_count == 8 || i == ciphertext.size() - 1) {
			uint64_t plain = RSA::modPow(block, prikey.d, prikey.n);
			for (int j = RSA::BLOCK_SIZE - 1; j >= 0; j--) {
				plaintext.push_back((plain >> (j * 8)) & 0xff);
			}
			block = 0;
			byte_count = 0;
		}
	}

	return plaintext;
}

uint64_t RSA::encrypt(uint64_t plaintext, PublicKey pubkey) {
	return RSA::modPow(plaintext, pubkey.e, pubkey.n);
}

uint64_t RSA::decrypt(uint64_t ciphertext, PrivateKey prikey) {
	return RSA::modPow(ciphertext, prikey.d, prikey.n);
}

uint64_t RSA::modMul(uint64_t a, uint64_t b, uint64_t mod) {
	uint64_t result = 0;
	a %= mod;
	while (b > 0) {
		if (b & 1) {
			result = (result + a) % mod;
		}
		a = (2 * a) % mod;
		b >>= 1;
	}
	return result;
}

uint64_t RSA::modPow(uint64_t base, uint64_t exp, uint64_t mod) {
	uint64_t result = 1;
	base = base % mod;
	while (exp > 0) {
		if (exp & 1) {
			result = RSA::modMul(result, base, mod);
		}
		base = RSA::modMul(base, base, mod);
		exp >>= 1;
	}
	return result;
}

uint64_t RSA::modInverse(uint64_t a, uint64_t m) {
	int64_t x, y;
	RSA::exgcd(a, m, x, y);
	x = (x + m) % m;
	return x;
}

void RSA::exgcd(int64_t a, int64_t b, int64_t& x, int64_t& y) {
	if (b == 0) x = 1, y = 0;
	else exgcd(b, a % b, y, x), y -= (a / b) * x;
}

uint64_t RSA::gcd(uint64_t a, uint64_t b) {
	return b ? gcd(b, a % b) : a;
}

bool RSA::millerRabin(uint64_t n, int iter) {
	if (n < 4) return n == 2 || n == 3;
	if (n % 2 == 0) return false;
	// 写 n - 1 为 2^s * d 的形式
	uint64_t s = 0;
	uint64_t d = n - 1;
	while ((d & 1) == 0) {
		d >>= 1;
		++s;
	}
	std::uniform_int_distribution<uint64_t> distribution(2, n - 2);
	std::random_device rd;
	std::mt19937_64 gen(rd());
	for (int i = 0; i < iter; i++) {
		uint64_t a = distribution(gen);
		uint64_t x = RSA::modPow(a, d, n);
		if (x == 1 || x == n - 1) continue;
		for (uint64_t j = 1; j < s; j++) {
			x = RSA::modMul(x, x, n);
			if (x == n - 1) break;
		}
		if (x != n - 1) return false;
	}
	return true;
}

uint64_t RSA::genPrime(int bits) {
	static std::random_device rd;
	static std::mt19937_64 gen(rd());
	uint64_t hbit = 1ULL << (bits - 1);
	uint64_t lbit = 1ULL << bits;
	std::uniform_int_distribution<uint64_t> dis(hbit, lbit - 1);
	uint64_t n = 0;
	do {
		n = dis(gen);
	} while (!RSA::millerRabin(n, 100));
	return n;
}

std::vector<uint8_t> RSA::strToVec(const std::string& hex_str) {
	if (hex_str.length() % 2 != 0) {
		throw std::invalid_argument("Hex string must have an even length");
	}
	std::vector<uint8_t> bytes;
	for (size_t i = 0; i < hex_str.length(); i += 2) {
		std::string byteString = hex_str.substr(i, 2);
		uint8_t byte = static_cast<uint8_t>(std::stoi(byteString, nullptr, 16));
		bytes.push_back(byte);
	}
	return bytes;
}

std::string RSA::vecToStr(const std::vector<uint8_t>& data) {
	std::string hex_str;
	hex_str.reserve(data.size() * 2);
	for (uint8_t byte : data) {
		char high = "0123456789ABCDEF"[byte >> 4];
		char low = "0123456789ABCDEF"[byte & 0x0F];
		hex_str.push_back(high);
		hex_str.push_back(low);
	}
	return hex_str;
}