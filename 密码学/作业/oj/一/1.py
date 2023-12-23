l = 4
m = 4
Nr = 4
Sbox = ['E', '4', 'D', '1', '2', 'F', 'B', '8',
         '3', 'A', '6', 'C', '5', '9', '0', '7']
Pbox = [1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16]

def _xor(w, K):
    assert len(w) == len(K)
    u = ''
    for _w, _k in zip(w, K):
        u += str(int(_w) ^ int(_k))
    return u

def _sbox(u):
    v = ''
    for i in range(m):
        ui = u[i * l : i * l + l]
        vi = format(int(Sbox[int(ui, 2)], 16), '04b')
        v += vi
    return v
        
def _pbox(v):
    assert len(v) == l * m
    w = ''
    for i in range(len(v)):
        w += v[Pbox[i] - 1]
    return w


def spn(plain, key):
    keys = [key[i * Nr : i * Nr + l * m] for i in range(Nr + 1)]
    w = plain
    for r in range(Nr - 1):
        u = _xor(w, keys[r])
        v = _sbox(u)
        w = _pbox(v)
    u = _xor(w, keys[Nr - 1])    
    v = _sbox(u)
    y = _xor(v, keys[Nr])
    return y

    
if __name__ == '__main__':
    plain, key = input().split()
    y = spn(plain, key)
    print(y)