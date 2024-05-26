# main.py

from crypto_module import SearchableEncryption
from faker import Faker
import os

# 定义密钥和文档
key = os.urandom(32)  # 生成随机密钥
se = SearchableEncryption(key)
fake = Faker()  # 初始化Faker

# 全局参数
NUM_DOCUMENTS = 1000  # 文档数量
SENTENCES_PER_DOCUMENT = 3  # 每个文档的句子数量

documents = {}

for doc_id in range(1, NUM_DOCUMENTS + 1):
    document = ' '.join(fake.sentence() for _ in range(SENTENCES_PER_DOCUMENT))
    documents[doc_id] = document
    
print(f'Generate Docs: {len(documents)}')

# 加密文档并创建索引
encrypted_docs = {doc_id: se.encrypt(text) for doc_id, text in documents.items()}
index = se.create_index(documents)

# 搜索
keywords = ["quick", "town", "enemy"]
results = {}

for keyword in keywords:
    trapdoor = se.generate_trapdoor(keyword)
    found_docs = se.search(index, trapdoor)
    results[keyword] = found_docs

# 显示结果
for keyword, found_docs in results.items():
    print(f"Keyword '{keyword}': Found Documents IDs {found_docs}")
    for doc_id in found_docs:
        print(f"  Document {doc_id}: {se.decrypt(encrypted_docs[doc_id])}")