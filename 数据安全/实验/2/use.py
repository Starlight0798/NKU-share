from phe import paillier # 开源库
import time # 做性能测试
##################### 设置参数
print("默认私钥大小：", paillier.DEFAULT_KEYSIZE)
#生成公私钥
public_key, private_key = paillier.generate_paillier_keypair()
# 测试需要加密的数据
message_list = [3.1415926,100,-4.6e-12]
##################### 加密操作
time_start_enc = time.time()
encrypted_message_list = [public_key.encrypt(m) for m in message_list]
time_end_enc = time.time()
print("加密耗时s：",time_end_enc-time_start_enc)
print("加密数据（3.1415926）:",encrypted_message_list[0].ciphertext())
##################### 解密操作
time_start_dec = time.time()
decrypted_message_list = [private_key.decrypt(c) for c in encrypted_message_list]
time_end_dec = time.time()
print("解密耗时s：",time_end_dec-time_start_dec)
print("原始数据（3.1415926）:",decrypted_message_list[0])
##################### 测试加法和乘法同态
a,b,c = encrypted_message_list # a,b,c分别为对应密文
a_sum = a + 5 # 密文加明文，已经重载了+运算符
a_sub = a - 3 # 密文加明文的相反数，已经重载了-运算符
b_mul = b * 6 # 密文乘明文,数乘
c_div = c / -10.0 # 密文乘明文的倒数
print("a+5 密文:",a.ciphertext()) # 密文纯文本形式
print("a+5=",private_key.decrypt(a_sum))
print("a-3",private_key.decrypt(a_sub))
print("b*6=",private_key.decrypt(b_mul))
print("c/-10.0=",private_key.decrypt(c_div))
##密文加密文
print((private_key.decrypt(a)+private_key.decrypt(b))==private_key.decrypt(a+b))
#报错，不支持a*b，即两个密文直接相乘
#print((private_key.decrypt(a)+private_key.decrypt(b))==private_key.decrypt(a*b))