import pickle
import numpy as np

train_user_pkl = './data/train_user.pkl'
train_item_pkl = './data/train_item.pkl'

"""
Number of users: 19835
Number of rated items: 455705
Number of ratings: 5001507
Max user ID: 19834
Max item ID: 624960
"""

user_num = 19835
item_num = 455705
ratings_num = 5001507

def get_bias(train_data_user, train_data_item):
    """
    :param train_data_user: 用户-[物品，评分]字典
    :param train_data_item: 物品-[用户，评分]字典
    :return: 全评分均值，用户偏差, 物品偏差
    """
    miu = 0.0
    bx = np.zeros(user_num, dtype=np.float64)
    bi = np.zeros(item_num, dtype=np.float64)
    for user_id in train_data_user:
        sum = 0.0
        for item_id, score in train_data_user[user_id]:
            miu += score
            sum += score
        bx[user_id] = sum / len(train_data_user[user_id])
    miu /= ratings_num

    for item_id in train_data_item:
        sum = 0.0
        for user_id, score in train_data_item[item_id]:
            sum += score
        bi[item_id] = sum / len(train_data_item[item_id])

    bx -= miu
    bi -= miu
    return miu, bx, bi


if __name__ == '__main__':
    print('Loading data...')
    # 读取以用户ID为键，[物品ID，评分]为值的字典
    with open(train_user_pkl, 'rb') as f:
        train_user_data = pickle.load(f)
    # 读取以物品ID为键，[用户ID，评分]为值的字典
    with open(train_item_pkl, 'rb') as f:
        train_item_data = pickle.load(f)
    print('Data loaded.')

    # 计算总体偏差，用户偏差，物品偏差
    miu, bx, bi = get_bias(train_user_data, train_item_data)

    print('Saving data...')
    # 保存用户偏差
    with open('./data/bx.pkl', 'wb') as f:
        pickle.dump(bx, f)
    # 保存物品偏差
    with open('./data/bi.pkl', 'wb') as f:
        pickle.dump(bi, f)
    print('Data saved.')

    print('评分均值：', miu)
