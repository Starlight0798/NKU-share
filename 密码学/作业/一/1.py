from collections import defaultdict
import numpy as np

alphabet = [chr(ord('A') + i) for i in range(26)]
pi = [
        0.082, 0.015, 0.028, 0.043, 0.127, 0.022,
        0.020, 0.061, 0.070, 0.002, 0.008, 0.040,
        0.024, 0.067, 0.075, 0.019, 0.001, 0.060,
        0.063, 0.091, 0.028, 0.010, 0.023, 0.001,
        0.020, 0.001
     ]
     
def Hash(string):
    _n = len(string)
    hash = defaultdict(int)
    for s in string:
        hash[s] += 1
    return hash, _n
         
         
def Ic(string):
    hash, _n = Hash(string)
    _sum = sum([hash[i] * (hash[i] - 1) for i in alphabet])
    return _sum / (_n * (_n - 1))


def split_str(string, m):
    _str = ["" for _ in range(m)]
    for i, s in enumerate(string):
        _str[i % m] += s
    return _str


def cal_m(string):
    m_val = [0.0]
    for m in range(1, 11):
        print(f'm={m}', end=' ')
        sstr = split_str(string, m)
        _sum = 0.0
        for s in sstr:
            ic = Ic(s)
            _sum += ic
            print(f'{ic:.5f}', end=' ')
        print()
        m_val.append(_sum / m)
    _m = np.array(m_val).argmax(axis=0)
    print(f'Get m = {_m}')
    return _m


def get_key(string):
    m = cal_m(string)
    _str = split_str(string, m)
    key = []
    for s in _str:
        print(s + ' --> ', end='')
        hash, _n = Hash(s)
        Mg = []
        for g in range(26):
            mg = 0.0
            for i in range(26):
                mg += pi[i] * hash[alphabet[(i + g) % 26]]
            mg /= _n
            Mg.append(mg)
        k = np.abs(np.array(Mg) - np.array(0.065)).argmin(axis=0)
        key.append(k)
        print(f'k = {k}, Mg({k}) = {Mg[k]:.5f}')
    return key


def decrypt(string, key):
    plain = ""
    n = len(key)
    for i, s in enumerate(string):
        f = ord(s) - ord('A')
        k = key[i % n]
        plain += alphabet[(f - k + 26) % 26]
    return plain.lower()
    
        
if __name__ == "__main__":
    cipher = "KCCPKBGUFDPHQTYAVINRRTMVGRKDNBVFDETDGILTXRGUDDKOTF" \
         "MBPVGEGLTGCKQRACQCWDNAWCRXIZAKFTLEWRPTYCQKYVXCHKFT" \
         "PONCQQRHJVAJUWETMCMSPKQDYHJVDAHCTRLSVSKCGCZQQDZXGS" \
         "FRLSWCWSJTBHAFSIASPRJAHKJRJUMVGKMITZHFPDISPZLVLGWT" \
         "FPLKKEBDPGCEBSHCTJRWXBAFSPEZQNRWXCVYCGAONWDDKACKAW" \
         "BBIKFTIOVKCGGHJVLNHIFFSQESVYCLACNVRWBBIREPBBVFEXOS" \
         "CDYGZWPFDTKFQIYCWHJVLNHIQIBTKHJVNPIST"
         
    key = get_key(cipher.upper())
    print(f'key = {key}')
    
    plain_text = decrypt(cipher, key)
    print(f'plain_text: {plain_text}')