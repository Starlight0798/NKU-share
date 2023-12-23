'''
Author: qmj
'''

import numpy as np
import os

file_path = '../../Data.txt'
teleport_parameter = 0.85

def read_data(file_path):
    """
    读取数据，构建图并返回图数据和所有节点的集合。
    """
    graph = {}
    all_nodes = set()

    with open(file_path, 'r') as file:
        for line in file:
            from_node, to_node = map(int, line.strip().split())
            all_nodes.add(from_node)
            all_nodes.add(to_node)
            if from_node not in graph.keys():
                graph[from_node] = []
            graph[from_node].append(to_node)

    return graph, all_nodes

def page_rank_reverse(graph, all_nodes, teleport_parameter = 0.85):
    """
    基于给定的图、节点和参数，使用逆矩阵方法计算PageRank值。
    """
    N = len(all_nodes)
    node_idx = {node: i for i, node in enumerate(sorted(all_nodes))}

    # 构建转移矩阵S
    S = np.zeros([N, N], dtype = np.float64)
    for out_node, in_nodes in graph.items():
        for in_node in in_nodes:
            S[node_idx[in_node], node_idx[out_node]] = 1

    # 处理矩阵
    for col in range(N):
        if (sum_of_col := S[:, col].sum()) == 0:
            S[:, col] = 1 / N
        else:
            S[:, col] /= sum_of_col
            
    E = np.identity(N, dtype = np.float64)
    ET = np.ones((N, 1), dtype = np.float64)
    # 直接使用逆矩阵计算结果
    P = np.linalg.inv(E - teleport_parameter * S) @ ((1 - teleport_parameter) / N * ET).flatten()

    return P, node_idx

def top_nodes(pr, node_idx, num_top_nodes = 100):
    """
    返回前100个具有最高PageRank值的节点及其PageRank值。
    """
    sorted_nodes = sorted(node_idx.items(), key = lambda x: pr[x[1]], reverse = True)
    return [(node, pr[index]) for node, index in sorted_nodes[:num_top_nodes]]

def write_result(file_path, top_100_nodes):
    """
    将结果写入文件。
    """
    if not os.path.exists(file_path):
        os.makedirs(os.path.dirname(file_path))
    with open(file_path, 'w') as file:
        for node, rank in top_100_nodes:
            file.write(f'{node} {rank}\n')

def main():
    graph, all_nodes = read_data(file_path)
    pr, node_idx = page_rank_reverse(graph, all_nodes, teleport_parameter)
    top_100_nodes = top_nodes(pr, node_idx)
    write_result('./results/basic_result.txt', top_100_nodes)
    print(f'Top 100 Nodes with their PageRank scores (teleport parameter = {teleport_parameter}):')
    for node, rank in top_100_nodes:
        print(f'NodeID: {node}, PageRank: {rank}')

if __name__ == '__main__':
    main()