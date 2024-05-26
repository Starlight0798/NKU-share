'''
Author: qmj
'''

import numpy as np
from collections import defaultdict

class SparseGraph:
    def __init__(self, dtype = np.float64):
        """
        初始化稀疏图。

        参数:
            data (dict): 一个表示图的字典，形式是{source_node: (outdegree, [destination_nodes])}，默认为 None。
            dtype: 数据类型，默认为 np.float64。
        """
        self.data = defaultdict(lambda: (0, []))
        self.all_nodes = set()
        self.dtype = dtype
        
    def __getitem__(self, source):
        """
        通过下标访问源节点的出度和目标节点列表。

        参数:
            source: 源节点。

        返回:
            tuple: 一个元组，包含源节点的出度和目标节点列表。
        """
        return self.data[source]

    def __contains__(self, source):
        """
        判断源节点是否在图中。

        参数:
            source: 源节点。

        返回:
            bool: 如果源节点在图中，返回True，否则返回False。
        """
        return source in self.data
    
    def __str__(self):
        """
        将稀疏图转换为字符串表示。

        返回:
            str: 稀疏图的字符串表示。
        """
        return f"SparseGraph(data={self.data})"

    def add_edge(self, source, destination):
        """
        添加一条从源节点到目标节点的边。

        参数:
            source: 源节点。
            destination: 目标节点。
        """
        self.all_nodes.add(source)
        self.all_nodes.add(destination)
        
        if destination not in self.data:
            self.data[destination] = (0, [])
            
        if source not in self.data:
            self.data[source] = (1, [destination])
            
        else:
            outdegree, destinations = self.data[source]
            destinations.append(destination)
            self.data[source] = (outdegree + 1, destinations)

    def get_outdegree(self, source):
        """
        获取源节点的出度。

        参数:
            source: 源节点。

        返回:
            int: 源节点的出度。
        """
        return self.data[source][0] if source in self.data else 0

    def get_destinations(self, source):
        """
        获取源节点连接的目标节点列表。

        参数:
            source: 源节点。

        返回:
            list: 目标节点列表。
        """
        return self.data[source][1] if source in self.data else []

    def get_sources(self):
        """
        获取所有源节点。

        返回:
            list: 源节点列表。
        """
        return list(self.data.keys())
    
    def get_no_outdegree_nodes(self):
        """
        获取出度为0的节点。

        返回:
            list: 出度为0的节点列表。
        """
        return [node for node in self.data if self.data[node][0] == 0]
    
    def get_all_nodes(self):
        """
        获取所有节点。

        返回:
            list: 所有节点的列表。
        """
        return list(self.all_nodes)



