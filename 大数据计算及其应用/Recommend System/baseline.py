from collections import defaultdict
from process import load_pkl
import numpy as np

test_pkl = './data/test.pkl'
bx_pkl = './data/bx.pkl'
bi_pkl = './data/bi.pkl'
idx_pkl = './data/node_idx.pkl'


class Baseline:
    def __init__(self, data_path='./data/train_user.pkl'):
        self.bx = load_pkl(bx_pkl)  # 用户偏置
        self.bi = load_pkl(bi_pkl)  # 物品偏置
        self.idx = load_pkl(idx_pkl)
        self.train_user_data = load_pkl(data_path)
        self.test_data = load_pkl(test_pkl)
        self.globalmean = self.get_globalmean()  # 全局平均分


    def get_globalmean(self):
        score_sum, count = 0.0, 0
        for user_id, items in self.train_user_data.items():
            for item_id, score in items:
                score_sum += score
                count += 1
        return score_sum / count


    def predict(self, user_id, item_id):
        pre_score = self.globalmean + \
            self.bx[user_id] + \
            self.bi[item_id]
        return pre_score


    def rmse(self):
        loss, count = 0.0, 0
        for user_id, items in self.train_user_data.items():
            for item_id, score in items:
                loss += (score - self.predict(user_id, item_id)) ** 2
                count += 1
        return np.sqrt(loss / count)


    def test(self, write_path='./result/result.txt'):
        print('Start testing...')
        predict_score = defaultdict(list)
        for user_id, item_list in self.test_data.items():
            for item_id in item_list:
                if item_id not in self.idx:
                    pre_score = self.globalmean * 10
                else:
                    new_id = self.idx[item_id]
                    pre_score = self.predict(user_id, new_id) * 10
                    if pre_score > 100.0:
                        pre_score = 100.0
                    elif pre_score < 0.0:
                        pre_score = 0.0

                predict_score[user_id].append((item_id, pre_score))
        print('Testing finished.')

        def write_result(predict_score, write_path):
            print('Start writing...')
            with open(write_path, 'w') as f:
                for user_id, items in predict_score.items():
                    f.write(f'{user_id}|6\n')
                    for item_id, score in items:
                        f.write(f'{item_id} {score}\n')
            print('Writing finished.')

        if write_path:
            write_result(predict_score, write_path)
        return predict_score



if __name__ == '__main__':
    baseline = Baseline()

    baseline.test(write_path='./result/baseline.txt')
    rmse = baseline.rmse()
    print(f'RMSE: {rmse:.6f}')