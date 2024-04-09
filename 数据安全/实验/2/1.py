from phe import paillier
import random

# 假设的服务器端消息
server_messages = [10, 20, 30, 40, 50]  # 服务器保存的消息列表
length = len(server_messages)

# 生成Paillier密钥对
public_key, private_key = paillier.generate_paillier_keypair()

# 客户端知道它想要的消息索引
index = random.randint(0, len(server_messages) - 1)
print(f"客户端想要的消息索引是: {index}")

# 客户端生成加密的选择向量
select_vector = [public_key.encrypt(int(i == index)) for i in range(length)]
print(f"客户端生成的加密选择向量是: {select_vector}")

# 服务器计算加密的总和
encrypted_sum = sum(server_messages[i] * select_vector[i] for i in range(length))
print(f"服务器计算的加密总和是: {encrypted_sum}")

# 客户端解密以获取感兴趣的消息
desired_message = private_key.decrypt(encrypted_sum)
print(f"客户端获取的消息是: {desired_message}")
