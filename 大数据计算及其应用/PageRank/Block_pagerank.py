'''
Author: ljh
'''

import numpy as np
import os
import json

# 将数据分成不同的块
def block_data(blocks=10):
    file_path = '../../Data.txt'
    # 处理数据，得到dead node 并且统计每个节点的度
    nodes = {}
    with open(file_path, 'r') as file:
        for line in file:
            from_node, to_node = map(int, line.strip().split())
            if from_node not in nodes.keys():
                nodes[from_node] = 0
            if to_node not in nodes.keys():
                nodes[to_node] = 0
            nodes[from_node] += 1

    num_nodes = len(nodes)  # 记录节点数量
    nodes_degree = list(sorted(nodes.items(), key=lambda x: x[0]))  # 记录度
    node_idx = {node[0]: i for i, node in enumerate(nodes_degree)}  # 记录映射

    print("-------- Start to load blocks ---------")

    A_block_num = num_nodes // blocks
    block_data = [{node: [] for node in nodes} for _ in range(blocks)]

    with open(file_path, 'r') as f:
        for line in f:
            from_node, to_node = map(int, line.strip().split())
            block_index = (node_idx[to_node] // A_block_num) if (node_idx[to_node] // A_block_num) < (blocks) else blocks - 1
            block_data[block_index][from_node].append(to_node)

    if not os.path.exists("./Block_matrix"):
        os.mkdir("./Block_matrix")

    print('--------- 保存矩阵 ----------')
    for block in range(blocks):
        save_matrix(block_data[block], block)

    print("-------- load all blocks! ---------")
    return nodes_degree, node_idx

# 保存矩阵
def save_matrix(data, indx):
    matrix_pathname = './Block_matrix/Block' + str(indx) + '.matrix'
    with open(matrix_pathname, 'w+', encoding='utf-8') as f:
        json.dump(data, f)

# 读取矩阵
def read_matrix(indx):
    matrix_pathname = './Block_matrix/Block' + str(indx) + '.matrix'
    with open(matrix_pathname, 'r+', encoding='utf-8') as f:
        return json.load(f)

# 保存向量
def save_vector(data, indx, new=False):
    suffix = '.new' if new else '.old'
    r_pathname = './RVector/r' + str(indx) + suffix
    with open(r_pathname, 'w+', encoding='utf-8') as f:
        json.dump(data, f)

# 读取向量
def read_vector(indx, new=False):
    suffix = '.new' if new else '.old'
    r_pathname = './RVector/r' + str(indx) + suffix
    with open(r_pathname, 'r+', encoding='utf-8') as f:
        return json.load(f)

# 读取数据
def read_data(file_path):
    graph = {}
    all_nodes = set()

    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            from_node, to_node = map(int(line.strip().split()))
            all_nodes.add(from_node)
            all_nodes.add(to_node)
            if from_node not in graph.keys():
                graph[from_node] = []
            graph[from_node].append(to_node)
            
    return graph, all_nodes

# 初始化向量
def initial_r(all_nodes, blocks=10, teleport_parameter=0.85):
    print("----------- initial vector -----------")
    if not os.path.exists("./RVector"):
        os.mkdir("./RVector")
    num_nodes = len(all_nodes)
    A_block_num = num_nodes // blocks
    R_old = np.ones(num_nodes) / num_nodes
    R_new = np.array([(1 - teleport_parameter) / num_nodes for _ in range(num_nodes)])
    for block in range(blocks):
        if block < blocks - 1:
            save_vector(R_old[block * A_block_num: block * A_block_num + A_block_num].tolist(), block, False)
            save_vector(R_new[block * A_block_num: block * A_block_num + A_block_num].tolist(), block, True)
        else:
            save_vector(R_old[block * A_block_num:].tolist(), block, False)
            save_vector(R_new[block * A_block_num:].tolist(), block, True)
    print("----------- vector has ready！------------")

# 计算分块PageRank
def block_calculate_rank(nodes_degree, node_idx, blocks=10, teleport_parameter=0.85, tol=1e-8, iter_num=0):
    num_nodes = len(nodes_degree)
    while True:
        theta = 0
        iter_num += 1
        for block in range(blocks):
            # 读取 Block Matrix 初始r_new
            graph = read_matrix(block)
            r_new = np.array(read_vector(block, True))
            block_base = num_nodes // blocks * block

            for p_block in range(blocks):
                base = num_nodes // blocks * p_block  # 计算全局下标
                r_old = np.array(read_vector(p_block))

                for rx, weight_rx in enumerate(r_old):
                    rx_global_idx = rx + base # 全局下标
                    rx_name = str(nodes_degree[rx_global_idx][0])
                    # 模拟取Matrix中的一条
                    degree_rx = nodes_degree[rx_global_idx][1]
                    if degree_rx > 0:
                        for destination in graph[rx_name]:
                            des_idx = node_idx[destination] - block_base
                            r_new[des_idx] = (teleport_parameter * weight_rx) / degree_rx + r_new[des_idx]

                    else:
                        # dead node
                        r_new += teleport_parameter / num_nodes * weight_rx

            r_old = np.array(read_vector(block))
            save_vector(r_new.tolist(), block, False)

            # 判断收敛
            theta += np.abs(r_new - r_old).sum()
        if theta < tol:
            print(f'迭代{iter_num}次')
            break


# 计算pageRank
def page_rank_matrix(graph, all_nodes, teleport_parameter=0.85, tol=1e-8, iter_num=0):
    num_nodes = len(all_nodes)
    all_nodes = list(sorted(all_nodes))
    node_idx = {node: i for i, node in enumerate(all_nodes)}
    r_old = np.ones(num_nodes) / num_nodes
    while True:
        iter_num += 1
        r_new = np.array([(1 - teleport_parameter) / num_nodes for _ in range(num_nodes)])
        for rx_global_idx, weight_rx in enumerate(r_old):
            rx_name = all_nodes[rx_global_idx]
            if rx_name in graph.keys():
                degree_rx = len(graph[rx_name])
                for destination in graph[rx_name]:
                    des_idx = node_idx[destination]
                    r_new[des_idx] += teleport_parameter * weight_rx / degree_rx
            else:
                # 处理dead，统计dead节点数量Dn，每次更新后的r_new加上1/N*tele*Dn
                degree_rx = num_nodes
                r_new += teleport_parameter * 1 / degree_rx * weight_rx
        S = r_new.sum()
        r_new += (1-S) / num_nodes
        if np.abs(r_new - r_old).sum() < tol * len(r_old):
            print(f'迭代{iter_num}次')
            break
        r_old = r_new

    return r_old, node_idx
    
# 获取分块PageRank的前100个节点
def top_block(node_idx, blocks=10, num_top_nodes=100):
    num_nodes = len(node_idx)
    top = [0] * num_nodes
    for block in range(blocks):
        base = num_nodes // blocks * block
        if block == blocks - 1:
            top[base:] = read_vector(block)
        else:
            top[base:base+num_nodes//blocks] = read_vector(block)
    sorted_nodes = sorted(node_idx.items(), key=lambda x: top[x[1]], reverse=True)
    return [(node, top[index]) for node, index in sorted_nodes[:num_top_nodes]]

# 获取PageRank的前100个节点
def top_nodes(pr, node_idx, num_top_nodes=100):
    sorted_nodes = sorted(node_idx.items(), key=lambda x: pr[x[1]], reverse=True)
    return [(node, pr[index]) for node, index in sorted_nodes[:num_top_nodes]]

# 检查结果
def check():
    # 同basic比较
    with open('./results/basic_result.txt', 'r') as file:
        for i, x in enumerate(top_100_nodes):
            (Rnode, Rvalue) = file.readline().split()
            if x[0] == int(Rnode):
                print(f"第{i}个相同，误差为{abs(float(Rvalue) - x[1])}")
        print('check finished')
        
if __name__ == '__main__':
    teleport_parameter = 0.85
    nodes_degree, nodes_idx = block_data()
    initial_r(nodes_degree)
    block_calculate_rank(nodes_degree, nodes_idx)
    top_100_nodes = top_block(nodes_idx)
    print(f'Top 100 Nodes with their PageRank scores (teleport parameter = {teleport_parameter}):')
    for node, rank in top_100_nodes:
        print(f'NodeID: {node}, PageRank: {rank}')
    check()
