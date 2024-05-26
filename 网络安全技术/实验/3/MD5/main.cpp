#include "MD5.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

using namespace std;

// 功能函数声明
void showHelp();
void testMD5();
void computeMD5(const string& filePath);
void validateMD5Manual(const string& filePath);
void validateMD5File(const string& filePath, const string& md5FilePath);

// 主函数
int main(int argc, char* argv[]) {
	if (argc < 2) {
		showHelp();
		return 1;
	}

	string option = argv[1];

	if (option == "-h") {
		showHelp();
	}
	else if (option == "-t") {
		testMD5();
	}
	else if (option == "-c" && argc == 3) {
		computeMD5(argv[2]);
	}
	else if (option == "-v" && argc == 3) {
		validateMD5Manual(argv[2]);
	}
	else if (option == "-f" && argc == 4) {
		validateMD5File(argv[2], argv[3]);
	}
	else {
		cout << "Invalid option or missing arguments\n";
		showHelp();
		return 1;
	}

	return 0;
}

// 帮助信息
void showHelp() {
	cout << "MD5: usage：[-h] --help information\n"
		<< "[-t] --test MD5 application\n"
		<< "[-c] [file path] --compute MD5 of the given file\n"
		<< "[-v] [file path] --validate the integrality of a given file by manual input MD5 value\n"
		<< "[-f] [file path of the file validated] [file path of the .md5 file] --validate the integrality of a given file by read MD5 value from .md5 file\n";
}

// 测试MD5
void testMD5() {
	cout << "Testing MD5 implementation..." << endl;
	MD5 md5;
	struct TestData {
		string input;
		string expectedHash;
	};

	vector<TestData> tests = {
		{"", "d41d8cd98f00b204e9800998ecf8427e"},
		{"a", "0cc175b9c0f1b6a831c399e269772661"},
		{"abc", "900150983cd24fb0d6963f7d28e17f72"},
		{"message digest", "f96b697d7cb7938d525a2f31aaf161d0"},
		{"abcdefghijklmnopqrstuvwxyz", "c3fcd3d76192e4007dfb496cca67e13b"},
		{"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "d174ab98d277d9f5a5611c2c9f419d9f"},
		{"12345678901234567890123456789012345678901234567890123456789012345678901234567890", "57edf4a22be3c955ac49da2e2107b67a"}
	};

	for (const auto& test : tests) {
		string result = md5.computeMD5(test.input);
		cout << "MD5(\"" << test.input << "\") = " << result;
		if (result == test.expectedHash) {
			cout << " [PASS]" << endl;
		}
		else {
			cout << " [FAIL]" << endl;
		}
	}
}

// 计算文件MD5
void computeMD5(const string& filePath) {
	ifstream file(filePath, ifstream::binary);
	if (!file) {
		cerr << "Cannot open file: " << filePath << endl;
		return;
	}

	stringstream buffer;
	buffer << file.rdbuf();
	string contents = buffer.str();

	MD5 md5;
	string result = md5.computeMD5(contents);
	cout << "MD5(" << filePath << ") = " << result << endl;
}

// 手动验证MD5
void validateMD5Manual(const string& filePath) {
	ifstream file(filePath, ifstream::binary);
	if (!file) {
		cerr << "Cannot open file: " << filePath << endl;
		return;
	}

	stringstream buffer;
	buffer << file.rdbuf();
	string contents = buffer.str();

	MD5 md5;
	string computedMD5 = md5.computeMD5(contents);

	string inputMD5;
	cout << "Enter the MD5 hash to validate: ";
	cin >> inputMD5;

	if (computedMD5 == inputMD5) {
		cout << "MD5 verification passed: " << computedMD5 << endl;
	}
	else {
		cout << "MD5 verification failed: " << computedMD5 << " (computed) != " << inputMD5 << " (expected)" << endl;
	}
}

// 通过.md5文件验证MD5
void validateMD5File(const string& filePath, const string& md5FilePath) {
	ifstream file(filePath, ifstream::binary);
	if (!file) {
		cerr << "Cannot open file: " << filePath << endl;
		return;
	}

	stringstream buffer;
	buffer << file.rdbuf();
	string contents = buffer.str();

	MD5 md5;
	string computedMD5 = md5.computeMD5(contents);

	ifstream md5File(md5FilePath);
	if (!md5File) {
		cerr << "Cannot open MD5 file: " << md5FilePath << endl;
		return;
	}

	string fileMD5;
	getline(md5File, fileMD5);

	if (computedMD5 == fileMD5) {
		cout << "MD5 verification passed: " << computedMD5 << endl;
	}
	else {
		cout << "MD5 verification failed: " << computedMD5 << " (computed) != " << fileMD5 << " (expected)" << endl;
	}
}