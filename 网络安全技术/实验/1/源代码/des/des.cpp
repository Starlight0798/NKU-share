﻿#include "pch.h"
#include "framework.h"
#include "des.h"
#include <assert.h>

DES::DES(const std::string& key) {
	std::bitset<64> realKey(std::stoull(key, nullptr, 16));
	genSubKeys(realKey);
}

std::vector<uint8_t> DES::pad(const std::vector<uint8_t>& data, size_t blockSize) {
	std::vector<uint8_t> paddedData = data;
	size_t padLength = blockSize - (data.size() % blockSize);
	for (size_t i = 0; i < padLength; i++) {
		paddedData.push_back(static_cast<uint8_t>(padLength));
	}
	return paddedData;
}

std::vector<uint8_t> DES::unpad(const std::vector<uint8_t>& data, size_t blockSize) {
	if (data.empty()) return {};
	size_t padLength = data.back();
	if (padLength > data.size() || padLength > blockSize) return data;
	return std::vector<uint8_t>(data.begin(), data.end() - padLength);
}

std::vector<uint8_t> DES::encrypt(const std::vector<uint8_t>& plaintext) {
	auto padText = pad(plaintext, 8);
	std::vector<uint8_t> ciphertext;
	for (size_t i = 0; i < padText.size(); i += 8) {
		std::bitset<64> block;
		for (int j = 0; j < 64; ++j) {
			set(block, j, (padText[i + j / 8] >> (7 - (j % 8))) & 0x01);
		}
		auto encBlock = execute(block, ENCRYPT);
		for (int j = 0; j < 8; ++j) {
			ciphertext.push_back(static_cast<uint8_t>((encBlock >> (56 - 8 * j)).to_ullong() & 0xFF));
		}
	}
	return ciphertext;
}

std::vector<uint8_t> DES::decrypt(const std::vector<uint8_t>& ciphertext) {
	std::vector<uint8_t> decText;
	for (size_t i = 0; i < ciphertext.size(); i += 8) {
		std::bitset<64> block;
		for (int j = 0; j < 64; ++j) {
			set(block, j, (ciphertext[i + j / 8] >> (7 - (j % 8))) & 0x01);
		}
		auto decBlock = execute(block, DECRYPT);
		for (int j = 0; j < 8; ++j) {
			decText.push_back(static_cast<uint8_t>((decBlock >> (56 - 8 * j)).to_ullong() & 0xFF));
		}
	}
	return unpad(decText, 8);
}

std::bitset<64> DES::execute(const std::bitset<64>& data, int mode) {
	std::bitset<64> block;
	for (int i = 0; i < 64; i++) {
		set(block, i, get(data, IP[i] - 1));
	}
	std::bitset<32> left(block.to_ullong() >> 32);
	std::bitset<32> right(block.to_ullong() & 0xFFFFFFFF);
	for (int round = 0; round < 16; round++) {
		std::bitset<32> rightExpanded = f(right, subKeys[mode == DECRYPT ? 15 - round : round]);
		std::bitset<32> temp = left ^ rightExpanded;
		left = right;
		right = temp;
		if (round == 15) {
			std::swap(left, right);
		}
	}
	block = (std::bitset<64>(left.to_ullong()) << 32) | std::bitset<64>(right.to_ullong());
	std::bitset<64> result;
	for (int i = 0; i < 64; i++) {
		set(result, i, get(block, FP[i] - 1));
	}
	return result;
}

std::bitset<32> DES::f(const std::bitset<32>& R, const std::bitset<48>& K) {
	std::bitset<48> block;
	for (int i = 0; i < 48; i++) {
		set(block, i, get(R, E_box[i] - 1));
	}
	block ^= K;
	std::bitset<32> result;
	for (int i = 0; i < 8; i++) {
		int row = (get(block, i * 6 + 5) << 1) + get(block, i * 6);
		int col = (get(block, i * 6 + 4) << 3) + (get(block, i * 6 + 3) << 2) + (get(block, i * 6 + 2) << 1) + get(block, i * 6 + 1);
		uint8_t sBoxVal = S_box[i][row][col];
		for (int k = 0; k < 4; k++) {
			set(result, i * 4 + k, (sBoxVal >> (3 - k)) & 1);
		}
	}
	std::bitset<32> output;
	for (int i = 0; i < 32; i++) {
		set(output, i, get(result, P_box[i] - 1));
	}
	return output;
}

void DES::genSubKeys(const std::bitset<64>& key) {
	std::bitset<56> realKey;
	for (int i = 0; i < 56; i++) {
		set(realKey, i, get(key, PC_1[i] - 1));
	}
	std::bitset<28> left(realKey.to_ullong() >> 28);
	std::bitset<28> right(realKey.to_ullong() & 0xFFFFFFF);
	for (int i = 0; i < 16; i++) {
		left = leftRotate(left, shift[i]);
		right = leftRotate(right, shift[i]);
		std::bitset<56> combined(left.to_string() + right.to_string());
		for (int j = 0; j < 48; j++) {
			set(subKeys[i], j, get(combined, PC_2[j] - 1));
		}
	}
}

template<size_t N>
std::bitset<N> DES::leftRotate(const std::bitset<N>& bits, int shift) {
	return (bits << shift) | (bits >> (N - shift));
}

const uint8_t DES::IP[64] = {
	58,50,42,34,26,18,10,2,60,52,44,36,28,20,12,4,
	62,54,46,38,30,22,14,6,64,56,48,40,32,24,16,8,
	57,49,41,33,25,17,9,1,59,51,43,35,27,19,11,3,
	61,53,45,37,29,21,13,5,63,55,47,39,31,23,15,7
};

const uint8_t DES::FP[64] = {
	40,8,48,16,56,24,64,32, 39,7,47,15,55,23,63,31,
	38,6,46,14,54,22,62,30, 37,5,45,13,53,21,61,29,
	36,4,44,12,52,20,60,28, 35,3,43,11,51,19,59,27,
	34,2,42,10,50,18,58,26, 33,1,41,9,49,17,57,25
};

const uint8_t DES::E_box[48] = {
	32,1,2,3,4,5,4,5,6,7,8,9,8,9,10,11,12,13,
	12,13,14,15,16,17,16,17,18,19,20,21,
	20,21,22,23,24,25,24,25,26,27,28,29,
	28,29,30,31,32,1
};

const uint8_t DES::P_box[32] = {
	16,7,20,21, 29,12,28,17, 1,15,23,26, 5,18,31,10,
	2,8,24,14,  32,27,3,9,   19,13,30,6, 22,11,4,25
};

const uint8_t DES::S_box[8][4][16] = {
	{
		0xe,0x0,0x4,0xf,0xd,0x7,0x1,0x4,0x2,0xe,0xf,0x2,0xb,
		0xd,0x8,0x1,0x3,0xa,0xa,0x6,0x6,0xc,0xc,0xb,0x5,0x9,
		0x9,0x5,0x0,0x3,0x7,0x8,0x4,0xf,0x1,0xc,0xe,0x8,0x8,
		0x2,0xd,0x4,0x6,0x9,0x2,0x1,0xb,0x7,0xf,0x5,0xc,0xb,
		0x9,0x3,0x7,0xe,0x3,0xa,0xa,0x0,0x5,0x6,0x0,0xd
	},
	{
		0xf,0x3,0x1,0xd,0x8,0x4,0xe,0x7,0x6,0xf,0xb,0x2,0x3,
		0x8,0x4,0xf,0x9,0xc,0x7,0x0,0x2,0x1,0xd,0xa,0xc,0x6,
		0x0,0x9,0x5,0xb,0xa,0x5,0x0,0xd,0xe,0x8,0x7,0xa,0xb,
		0x1,0xa,0x3,0x4,0xf,0xd,0x4,0x1,0x2,0x5,0xb,0x8,0x6,
		0xc,0x7,0x6,0xc,0x9,0x0,0x3,0x5,0x2,0xe,0xf,0x9
	},
	{
		0xa,0xd,0x0,0x7,0x9,0x0,0xe,0x9,0x6,0x3,0x3,0x4,0xf,
		0x6,0x5,0xa,0x1,0x2,0xd,0x8,0xc,0x5,0x7,0xe,0xb,0xc,
		0x4,0xb,0x2,0xf,0x8,0x1,0xd,0x1,0x6,0xa,0x4,0xd,0x9,
		0x0,0x8,0x6,0xf,0x9,0x3,0x8,0x0,0x7,0xb,0x4,0x1,0xf,
		0x2,0xe,0xc,0x3,0x5,0xb,0xa,0x5,0xe,0x2,0x7,0xc
	},
	{
		0x7,0xd,0xd,0x8,0xe,0xb,0x3,0x5,0x0,0x6,0x6,0xf,0x9,
		0x0,0xa,0x3,0x1,0x4,0x2,0x7,0x8,0x2,0x5,0xc,0xb,0x1,
		0xc,0xa,0x4,0xe,0xf,0x9,0xa,0x3,0x6,0xf,0x9,0x0,0x0,
		0x6,0xc,0xa,0xb,0xa,0x7,0xd,0xd,0x8,0xf,0x9,0x1,0x4,
		0x3,0x5,0xe,0xb,0x5,0xc,0x2,0x7,0x8,0x2,0x4,0xe
	},
	{
		0x2,0xe,0xc,0xb,0x4,0x2,0x1,0xc,0x7,0x4,0xa,0x7,0xb,
		0xd,0x6,0x1,0x8,0x5,0x5,0x0,0x3,0xf,0xf,0xa,0xd,0x3,
		0x0,0x9,0xe,0x8,0x9,0x6,0x4,0xb,0x2,0x8,0x1,0xc,0xb,
		0x7,0xa,0x1,0xd,0xe,0x7,0x2,0x8,0xd,0xf,0x6,0x9,0xf,
		0xc,0x0,0x5,0x9,0x6,0xa,0x3,0x4,0x0,0x5,0xe,0x3
	},
	{
		0xc,0xa,0x1,0xf,0xa,0x4,0xf,0x2,0x9,0x7,0x2,0xc,0x6,
		0x9,0x8,0x5,0x0,0x6,0xd,0x1,0x3,0xd,0x4,0xe,0xe,0x0,
		0x7,0xb,0x5,0x3,0xb,0x8,0x9,0x4,0xe,0x3,0xf,0x2,0x5,
		0xc,0x2,0x9,0x8,0x5,0xc,0xf,0x3,0xa,0x7,0xb,0x0,0xe,
		0x4,0x1,0xa,0x7,0x1,0x6,0xd,0x0,0xb,0x8,0x6,0xd
	},
	{
		0x4,0xd,0xb,0x0,0x2,0xb,0xe,0x7,0xf,0x4,0x0,0x9,0x8,
		0x1,0xd,0xa,0x3,0xe,0xc,0x3,0x9,0x5,0x7,0xc,0x5,0x2,
		0xa,0xf,0x6,0x8,0x1,0x6,0x1,0x6,0x4,0xb,0xb,0xd,0xd,
		0x8,0xc,0x1,0x3,0x4,0x7,0xa,0xe,0x7,0xa,0x9,0xf,0x5,
		0x6,0x0,0x8,0xf,0x0,0xe,0x5,0x2,0x9,0x3,0x2,0xc
	},
	{
		0xd,0x1,0x2,0xf,0x8,0xd,0x4,0x8,0x6,0xa,0xf,0x3,0xb,
		0x7,0x1,0x4,0xa,0xc,0x9,0x5,0x3,0x6,0xe,0xb,0x5,0x0,
		0x0,0xe,0xc,0x9,0x7,0x2,0x7,0x2,0xb,0x1,0x4,0xe,0x1,
		0x7,0x9,0x4,0xc,0xa,0xe,0x8,0x2,0xd,0x0,0xf,0x6,0xc,
		0xa,0x9,0xd,0x0,0xf,0x3,0x3,0x5,0x5,0x6,0x8,0xb
	}
};

const uint8_t DES::PC_1[56] = {
	57,49,41,33,25,17,9,1,58,50,42,34,26,18,
	10,2,59,51,43,35,27,19,11,3,60,52,44,36,
	63,55,47,39,31,23,15,7,62,54,46,38,30,22,
	14,6,61,53,45,37,29,21,13,5,28,20,12,4
};

const uint8_t DES::PC_2[48] = {
	14,17,11,24,1,5,3,28,15,6,21,10,
	23,19,12,4,26,8,16,7,27,20,13,2,
	41,52,31,37,47,55,30,40,51,45,33,48,
	44,49,39,56,34,53,46,42,50,36,29,32
};

const uint8_t DES::shift[16] = { 1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1 };