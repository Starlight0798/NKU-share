#include <iostream>
#include <bitset>
#include <string>
using namespace std;

// 经典的IP置换矩阵
const int IP[64] = {
    58, 50, 42, 34, 26, 18, 10, 2,
    60, 52, 44, 36, 28, 20, 12, 4,
    62, 54, 46, 38, 30, 22, 14, 6,
    64, 56, 48, 40, 32, 24, 16, 8,
    57, 49, 41, 33, 25, 17,  9, 1,
    59, 51, 43, 35, 27, 19, 11, 3,
    61, 53, 45, 37, 29, 21, 13, 5,
    63, 55, 47, 39, 31, 23, 15, 7
};

string hex_to_bin(const string &hex) {
    string binary;
    for (size_t i = 0; i < hex.size(); ++i) {
        bitset<4> temp(hex[i]);
        binary += temp.to_string();
    }
    return binary;
}

string bin_to_hex(const string &bin) {
    string hex;
    for (size_t i = 0; i < bin.size(); i += 4) {
        bitset<4> temp(bin.substr(i, 4));
        hex += "0123456789ABCDEF"[temp.to_ulong()];
    }
    return hex;
}

string initial_permutation(const string &input) {
    string output(64, '0');
    for (int i = 0; i < 64; ++i) {
        output[i] = input[IP[i] - 1];
    }
    return output;
}

int main() {
    string hex_data = "507239AA7EA3B82E";
    string binary_data = hex_to_bin(hex_data);
    cout << binary_data << endl;
    string permuted_binary_data = initial_permutation(binary_data);
    string permuted_hex_data = bin_to_hex(permuted_binary_data);

    cout << "IP置换后的十六进制数据: " << permuted_hex_data << endl;
    return 0;
}
