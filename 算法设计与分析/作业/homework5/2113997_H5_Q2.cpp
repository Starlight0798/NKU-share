#include <bits/stdc++.h>
using namespace std;
#define pii pair<int, int>

// 定义常量
const int MAXN = 1e5; // 最大节点数
const int INF = 0x3FFFFFFF; // 定义一个大的数作为初始距离
int dis[MAXN]; // 保存每个节点到源节点的最短距离
bool vis[MAXN]; // 标记一个节点是否已经被访问

vector<pii> G[MAXN]; // 邻接表表示有向图，保存每个节点的相邻节点及边的权重

// Dijkstra算法实现
void dijkstra(int n, int s) {
    priority_queue<pii, vector<pii>, greater<pii>> que; // 使用优先队列，每次选取距离最小的节点
    for (int i = 1; i <= n; i++) dis[i] = INF; // 初始化所有节点到源节点的距离为无穷大
    dis[s] = 0; // 源节点到自身的距离为0
    que.push({0, s}); // 将源节点放入优先队列
    while (!que.empty()) {
        int cur = que.top().second; // 获取当前距离最小的节点
        que.pop(); // 将节点从队列中移除
        if (vis[cur]) continue; // 如果节点已访问，跳过该节点
        vis[cur] = true; // 标记节点为已访问
        for (pii& nd : G[cur]) { // 遍历当前节点的相邻节点
            int to = nd.second, w = nd.first; // 获取相邻节点及边的权重
            if (dis[to] > dis[cur] + w) { // 判断是否找到了更短的路径
                dis[to] = dis[cur] + w; // 更新最短距离
                if (!vis[to]) que.push({dis[to], to}); // 如果相邻节点未访问，将其放入优先队列
            }
        }
    }
}

int main() {
    int n, m, s, u, v, w;
    cin >> n >> m >> s; // 读取输入：节点数n，边数m，源节点s
    for (int i = 0; i < m; i++) {
        cin >> u >> v >> w; // 读取边的信息：起始节点u，终止节点v，边的权重w
        G[u].push_back({w, v}); // 将边添加到邻接表
    }
    dijkstra(n, s); // 执行Dijkstra算法
    for (int i = 1; i <= n; i++) cout << dis[i] << " "; // 输出每个节点到源节点的最短距离
    return 0;
}
