import numpy as np
from svd import SVD

test_pkl = './data/test.pkl'
bx_pkl = './data/bx.pkl'
bi_pkl = './data/bi.pkl'
idx_pkl = './data/node_idx.pkl'

class SVD_Attr(SVD):
    def __init__(self, model_path='./model',
                 data_path='./data/train_user.pkl',
                 lr=5e-3,
                 lamda1=1e-2, lamda2=1e-2, lamda3=1e-2, lamda4=1e-3,
                 factor=50):
        super().__init__(model_path, data_path, lr, lamda1, lamda2, lamda3, lamda4, factor)
        self.attr1 = SVD(model_path='./model_attr1')
        self.attr2 = SVD(model_path='./model_attr2')
        self.attr1.load_weight()
        self.attr2.load_weight()

    def loss(self, is_valid=False):
        loss, count = 0.0, 0
        data = self.valid_data if is_valid else self.train_data
        # 如果是训练集
        if not is_valid:
            for user_id, items in data.items():
                for item_id, score in items:
                    loss += (score - self.predict(user_id, item_id)) ** 2
                    count += 1
            loss += self.lamda1 * np.sum(self.P ** 2)
            loss += self.lamda2 * np.sum(self.Q ** 2)
            loss += self.lamda3 * np.sum(self.bx ** 2)
            loss += self.lamda4 * np.sum(self.bi ** 2)
            loss /= count
        # 如果是验证集, 不需要正则化，同时结合另外两个属性模型的预测结果
        # 按0.8*本模型+0.1*属性1模型+0.1*属性2模型的比例计算loss
        else:
            for user_id, items in data.items():
                for item_id, score in items:
                    loss += (score - self.predict(user_id, item_id)) ** 2
                    count += 1
            loss *= 0.8
            loss += 0.1 * self.attr1.loss(is_valid=True)
            loss += 0.1 * self.attr2.loss(is_valid=True)
            loss /= count
        return loss

    def predict(self, user_id, item_id):
        return 0.8 * super().predict(user_id, item_id) + \
            0.1 * self.attr1.predict(user_id, item_id) + 0.1 * self.attr2.predict(user_id, item_id)


if __name__ == '__main__':
    attr = SVD_Attr(model_path='./model_attr_main')

    attr.train(epochs=10, save=True, load=True)

    # attr.test(write_path='./result/svd_attr1.txt')
    # rmse = attr.rmse()
    # print(f'RMSE: {rmse:.6f}')
