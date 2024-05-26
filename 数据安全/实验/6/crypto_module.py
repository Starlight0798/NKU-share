# crypto_module.py

from Crypto.Cipher import AES
from Crypto.Hash import SHA256, HMAC
from Crypto.Util.Padding import pad, unpad
from Crypto.Random import get_random_bytes
import base64

class SearchableEncryption:
    def __init__(self, key):
        self.key = key 

    def encrypt(self, text):
        """ 加密文本 """
        iv = get_random_bytes(16)  
        cipher = AES.new(self.key, AES.MODE_CBC, iv)
        encrypted_text = cipher.encrypt(pad(text.encode(), AES.block_size))
        return base64.b64encode(iv + encrypted_text).decode()

    def decrypt(self, encrypted_text):
        """ 解密文本 """
        data = base64.b64decode(encrypted_text)
        iv = data[:16]
        encrypted_text = data[16:]
        cipher = AES.new(self.key, AES.MODE_CBC, iv)
        original_text = unpad(cipher.decrypt(encrypted_text), AES.block_size)
        return original_text.decode()

    def generate_trapdoor(self, keyword):
        """ 生成陷门（加密关键词），依赖密钥的参与 """
        hmac = HMAC.new(self.key, digestmod=SHA256)
        hmac.update(keyword.encode())
        return base64.b64encode(hmac.digest()).decode()

    def create_index(self, documents):
        """ 创建倒排索引 """
        index = {}
        for doc_id, content in documents.items():
            words = set(content.split())
            for word in words:
                encrypted_word = self.generate_trapdoor(word)
                if encrypted_word in index:
                    index[encrypted_word].add(doc_id)
                else:
                    index[encrypted_word] = {doc_id}
        return index

    def search(self, index, trapdoor):
        """ 根据陷门进行搜索 """
        return index.get(trapdoor, set())
