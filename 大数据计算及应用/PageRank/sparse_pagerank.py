'''
Author: qmj
'''

import numpy as np
import os
from sparse_graph import SparseGraph

file_path = '../../Data.txt'
teleport_parameter = 0.85
tol = 1e-12

# 从文件中读取数据并构建图
def read_data(file_path):
    G = SparseGraph()
    with open(file_path, 'r') as file:
        for line in file:
            from_node, to_node = map(int, line.strip().split())
            G.add_edge(from_node, to_node)
    return G

# PageRank 算法的稀疏实现
def page_rank_sparse(G, beta, tol):
    N = len(G.all_nodes)
    ranks = np.array([1 / N] * N, dtype = np.float64)
    node_idx_map = {node: i for i, node in enumerate(G.all_nodes)}
    diff, iteration = float('inf'), 1

    while diff > tol:
        new_ranks = np.array([(1 - beta) / N] * N, dtype = np.float64)
        for node, (out_degree, dests) in G.data.items():
            if out_degree == 0:
                new_ranks += (beta * ranks[node_idx_map[node]]) / N
                continue
            rank_contribution = beta * ranks[node_idx_map[node]] / out_degree
            for dest in dests:
                new_ranks[node_idx_map[dest]] += rank_contribution
                
        new_ranks /= new_ranks.sum()
        diff = np.sum(np.abs(ranks - new_ranks))
        print(f'Iteration {iteration}: diff = {diff}')
        ranks = new_ranks
        iteration += 1

    return ranks

# 返回具有最高 PageRank 分数的节点
def top_nodes(pr, all_nodes, num_top_nodes=100):
    node_pr = list(zip(all_nodes, pr))
    sorted_nodes = sorted(node_pr, key=lambda x: x[1], reverse=True)
    return sorted_nodes[:num_top_nodes]

# 将结果写入文件
def write_result(file_path, top_100_nodes):
    if not os.path.exists(file_path):
        os.makedirs(os.path.dirname(file_path))
    with open(file_path, 'w') as file:
        for node, rank in top_100_nodes:
            file.write(f'{node} {rank}\n')

def main():
    graph = read_data(file_path)
    pr = page_rank_sparse(graph, teleport_parameter, tol)
    top_100_nodes = top_nodes(pr, graph.all_nodes)
    write_result('./results/sparse_result.txt', top_100_nodes)
    print(f'Top 100 Nodes with their PageRank scores (teleport parameter = {teleport_parameter}):')
    for node, rank in top_100_nodes:
        print(f'NodeID: {node}, PageRank: {rank}')

if __name__ == '__main__':
    main()
