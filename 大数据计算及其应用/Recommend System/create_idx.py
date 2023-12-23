import pickle

train_path = './data/train.txt'

def get_idx(train_path):
    all_nodes = set()
    with open(train_path, 'r') as f:
        while (line := f.readline()) != '':
            _, num = map(int, line.strip().split('|'))
            for _ in range(num):
                line = f.readline()
                item_id, _ = map(int, line.strip().split())
                all_nodes.add(item_id)
    node_idx = {node: idx for idx, node in enumerate(sorted(all_nodes))}
    return node_idx

if __name__ == '__main__':
    node_idx = get_idx(train_path)
    with open('./data/node_idx.pkl', 'wb') as f:
        pickle.dump(node_idx, f)
    print('done')