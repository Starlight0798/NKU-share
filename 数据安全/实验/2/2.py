from phe import paillier
import random

# 假设的服务器端消息和对称密钥k
server_messages = [10, 20, 30, 40, 50]
k = random.randint(1, 100)  # 对称密钥k，假设已安全共享给客户端和服务器
length = len(server_messages)

# 使用对称密钥k对服务器消息进行异或加密
encrypted_server_messages = [msg ^ k for msg in server_messages]

# 生成Paillier密钥对
public_key, private_key = paillier.generate_paillier_keypair()

# 客户端知道它想要的消息索引
index = random.randint(0, len(encrypted_server_messages) - 1)
print(f"客户端想要的消息索引是: {index}")

# 客户端生成加密的选择向量
select_vector = [public_key.encrypt(int(i == index)) for i in range(length)]
print(f"客户端生成的加密选择向量是: {select_vector}")

# 服务器计算加密的总和
encrypted_sum = sum(encrypted_server_messages[i] * select_vector[i] for i in range(length))
print(f"服务器计算的加密总和是: {encrypted_sum}")

# 客户端解密以获取感兴趣的加密消息
desired_encrypted_message = private_key.decrypt(encrypted_sum)
print(f"客户端获取的加密消息是: {desired_encrypted_message}")

# 使用对称密钥k对加密的消息进行解密
desired_message = desired_encrypted_message ^ k
print(f"使用对称密钥k解密后的消息是: {desired_message}")
