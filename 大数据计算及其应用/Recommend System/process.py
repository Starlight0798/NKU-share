import pickle
import numpy as np
from collections import defaultdict

train_path = './data/train.txt'
test_path = './data/test.txt'
attribute_path = './data/itemAttribute.txt'
idx_path = './data/node_idx.pkl'

def get_train_data(train_path, node_idx):
    data_user, data_item = defaultdict(list), defaultdict(list)
    with open(train_path, 'r') as f:
        while (line := f.readline()) != '':
            user_id, num = map(int, line.strip().split('|'))
            for _ in range(num):
                line = f.readline()
                item_id, score = line.strip().split()
                item_id, score = int(item_id), float(score)
                # 把0-100的得分映射到0-10
                score = score / 10
                data_user[user_id].append([node_idx[item_id], score])
                data_item[node_idx[item_id]].append([user_id, score])
    return data_user, data_item


def get_attribute_data(attribute_path, node_idx):
    attrs = defaultdict(list)
    with open(attribute_path, 'r') as f:
        while (line := f.readline()) != '':
            item_id, attr1, attr2 = line.strip().split('|')
            attr1 = 0 if attr1 == 'None' else 1
            attr2 = 0 if attr2 == 'None' else 1
            item_id = int(item_id)
            if item_id in node_idx:
                attrs[node_idx[item_id]].extend([attr1, attr2])
    return attrs


def get_data_by_attr(data_user, attrs):
    # 返回两份数据，第一份是有属性1的，第二份是有属性2的
    data1, data2 = defaultdict(list), defaultdict(list)
    for user_id, items in data_user.items():
        for item_id, score in items:
            if attrs[item_id]:
                if attrs[item_id][0] == 1:
                    data1[user_id].append([item_id, score])
                if attrs[item_id][1] == 1:
                    data2[user_id].append([item_id, score])
    return data1, data2

def get_test_data(test_path):
    data = defaultdict(list)
    with open(test_path, 'r') as f:
        while (line := f.readline()) != '':
            user_id, num = map(int, line.strip().split('|'))
            for _ in range(num):
                line = f.readline()
                item_id = int(line.strip())
                data[user_id].append(item_id)
    return data

def split_data(data_user, ratio=0.85, shuffle=True):
    train_data, valid_data = defaultdict(list), defaultdict(list)
    for user_id, items in data_user.items():
        if shuffle:
            np.random.shuffle(items)
        train_data[user_id] = items[:int(len(items) * ratio)]
        valid_data[user_id] = items[int(len(items) * ratio):]
    return train_data, valid_data


def load_pkl(pkl_path):
    with open(pkl_path, 'rb') as f:
        return pickle.load(f)

def store_data(pkl_path, data):
    with open(pkl_path, 'wb') as f:
        pickle.dump(data, f)


if __name__ == '__main__':
    print('Start to process data...')
    with open(idx_path, 'rb') as f:
        node_idx = pickle.load(f)
    user_data, item_data = get_train_data(train_path, node_idx)
    store_data(train_path.replace('.txt', '_user.pkl'), user_data)
    store_data(train_path.replace('.txt', '_item.pkl'), item_data)

    attr_data = get_attribute_data(attribute_path, node_idx)
    data1, data2 = get_data_by_attr(user_data, attr_data)
    store_data(attribute_path.replace('.txt', '.pkl'), attr_data)
    store_data(train_path.replace('.txt', '_attr1.pkl'), data1)
    store_data(train_path.replace('.txt', '_attr2.pkl'), data2)

    test_data = get_test_data(test_path)
    store_data(test_path.replace('.txt', '.pkl'), test_data)
    print('Done!')

