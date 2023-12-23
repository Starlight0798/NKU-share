#include <bits/stdc++.h>
#define MAXN 10000
using namespace std;

int df[MAXN], ra[MAXN];

// 并查集查找
int find(int x) { 
    // 如果x是其父节点，则直接返回x，否则通过路径压缩将x的父节点直接指向根节点
    return x == df[x] ? x : df[x] = find(df[x]); 
}

// 并查集合并
inline void merge(int a, int b) {
    // 找到a和b的根节点
    int x = find(a), y = find(b);
    if (x == y) return;
    // 如果x的秩比y大，则将y合并到x的树中
    if (ra[x] > ra[y]) df[y] = x;
    // 如果y的秩比x大，则将x合并到y的树中
    else if (ra[x] < ra[y]) df[x] = y;
    // 如果x和y的秩相同，则将x合并到y的树中，同时y的秩加1
    else { df[x] = y; ra[y]++; }
}

// 存储边的结构体，包括起点、终点和边权重
struct Edge {
    int u; // 起点
    int v; // 终点
    int w; // 边权重
    Edge(int u = 0, int v = 0, int w = 1) :u(u), v(v), w(w) {} // 构造函数
    bool operator<(const Edge& a)const { return w > a.w; } // 重载运算符，用于排序
};

priority_queue<Edge> que; // 存储边的优先队列

// 最小生成树Kruskal算法
int kruskal(int n) {
    // 初始化并查集
    for (int i = 1; i <= n; i++) { df[i] = i; ra[i] = 1; }
    int ans = 0;
    // 不断取出最小边进行合并
    while (!que.empty()) {
        Edge ed = que.top();
        que.pop();
        // 如果两个端点已经在同一个连通分量里，则无需再合并
        if (find(ed.u) == find(ed.v)) continue;
        merge(ed.u, ed.v);
        ans += ed.w; // 统计最小生成树的边权重和
    }
    return ans; // 返回最小生成树的边权重和
}

int main() {
    int n, m, u, v, w, ans;
    cin >> n >> m;
    // 读入边的信息，存入优先队列中
    for (int i = 1; i <= m; i++) {
        cin >> u >> v >> w;
        que.push(Edge(u, v, w));
    }
    ans = kruskal(n); 
	cout << ans; // 输出最小生成树的边权重和
	return 0;
}

