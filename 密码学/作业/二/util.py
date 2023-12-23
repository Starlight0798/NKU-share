import random

l = 4   # 每组比特数
m = 4   # 组数
Nr = 4  # 轮数
Sbox = [0xE, 0x4, 0xD, 0x1, 0x2, 0xF, 0xB, 0x8,
        0x3, 0xA, 0x6, 0xC, 0x5, 0x9, 0x0, 0x7]    # S盒
Pbox = [1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16]  # P盒


def reSbox(Sbox):
    '''
    生成逆S盒
    param Sbox: S盒
    '''
    reSbox = [0 for _ in Sbox]
    for i in range(len(Sbox)):
        reSbox[Sbox[i]] = i
    return reSbox


def xor(w, K):
    '''
    异或运算
    param w: 二进制字符串
    param K: 二进制字符串
    '''
    assert len(w) == len(K)
    u = ''
    for _w, _k in zip(w, K):
        u += str(int(_w) ^ int(_k))
    return u

def sbox(u):
    '''
    S盒运算
    param u: 二进制字符串
    '''
    v = ''
    for i in range(m):
        ui = u[i * l : i * l + l]
        vi = format(Sbox[int(ui, 2)], '04b')
        v += vi
    return v
        
def pbox(v):
    '''
    P盒运算
    param v: 二进制字符串
    '''
    assert len(v) == l * m
    w = ''
    for i in range(len(v)):
        w += v[Pbox[i] - 1]
    return w


def spn(plain, key):
    '''
    SPN加密算法
    param plain: 明文
    param key: 密钥
    '''
    keys = [key[i * Nr : i * Nr + l * m] for i in range(Nr + 1)]
    w = plain
    for r in range(Nr - 1):
        u = xor(w, keys[r])
        v = sbox(u)
        w = pbox(v)
    u = xor(w, keys[Nr - 1])    
    v = sbox(u)
    y = xor(v, keys[Nr])
    return y


def generate_key(n):
    '''
    生成密钥
    param n: 密钥个数
    '''
    keys = []
    for _ in range(n):
        key = ''
        for _ in range(l * m + 4 * Nr):
            key += str(random.randint(0, 1))
        keys.append(key)
    return keys


def generate_data(T, key):
    '''
    生成明文-密文对
    param T: 明文-密文对个数
    '''
    data = []
    for _ in range(T):
        plain = bin(random.randint(0, 2 ** (l * m) - 1))[2:].zfill(l * m)
        y = spn(plain, key)
        data.append((plain, y))
    return data
