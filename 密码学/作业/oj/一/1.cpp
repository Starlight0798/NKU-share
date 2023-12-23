#include <iostream>
#include <vector>
#include <string>
#include <bitset>
#include <cassert>

using namespace std;

const int l = 4;
const int m = 4;
const int Nr = 4;
const vector<char> Sbox = {'E', '4', 'D', '1', '2', 'F', 'B', '8',
                            '3', 'A', '6', 'C', '5', '9', '0', '7'};
const vector<int> Pbox = {1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16};

inline int hex2int(const char& c){
    if (c >= 'A') return c - 'A' + 10;
    else return c - '0';
}

string _xor(const string& w, const string& K) {
    assert(w.length() == K.length());
    string u;
    for (size_t i = 0; i < w.length(); ++i) {
        u += (w[i] == K[i] ? '0' : '1');
    }
    return u;
}

string _sbox(const string& u) {
    string v;
    for (int i = 0; i < m; ++i) {
        string ui = u.substr(i * l, l);
        int index = stoi(ui, nullptr, 2);
        v += bitset<4>(hex2int(Sbox[index])).to_string();
    }
    return v;
}

string _pbox(const string& v) {
    assert(v.length() == l * m);
    string w;
    for (size_t i = 0; i < v.length(); ++i) {
        w += v[Pbox[i] - 1];
    }
    return w;
}

string spn(const string& plain, const string& key) {
    vector<string> keys;
    for (int i = 0; i <= Nr; ++i) {
        keys.push_back(key.substr(i * Nr, l * m));
    }
    string w = plain;
    for (int r = 0; r < Nr - 1; ++r) {
        string u = _xor(w, keys[r]);
        string v = _sbox(u);
        w = _pbox(v);
    }
    string u = _xor(w, keys[Nr - 1]);
    string v = _sbox(u);
    string y = _xor(v, keys[Nr]);
    return y;
}

int main() {
    string plain, key;
    cin >> plain >> key;
    string y = spn(plain, key);
    cout << y;
    return 0;
}
