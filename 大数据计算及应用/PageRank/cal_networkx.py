'''
Author: qmj
'''

import networkx as nx
import os

file_path = '../../Data.txt'
teleport_parameter = 0.85
tol = 1e-12

def read_data(file_path):
    """
    读取数据，构建networkx图并返回。
    """
    graph = nx.DiGraph()
    with open(file_path, 'r') as file:
        for line in file:
            from_node, to_node = map(int, line.strip().split())
            graph.add_edge(from_node, to_node)
    return graph

def top_nodes(pr, num_top_nodes = 100):
    """
    返回前100个具有最高PageRank值的节点及其PageRank值。
    """
    sorted_nodes = sorted(pr.items(), key = lambda x:x[1], reverse = True)
    return sorted_nodes[:num_top_nodes]

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
    graph = read_data(file_path)
    pr = nx.pagerank(graph, alpha=teleport_parameter, tol=tol)
    top_100_nodes = top_nodes(pr)
    print(f'Top 100 Nodes with their PageRank scores (teleport parameter = {teleport_parameter}):')
    for node, rank in top_100_nodes:
        print(f'NodeID: {node}, PageRank: {rank}')
    write_result('./results/networkx_top_100_nodes.txt', top_100_nodes)

if __name__ == '__main__':
    main()