#include <bits/stdc++.h>
#define MAXN 10000
#define pii pair<int, int>
using namespace std;

const int INF = 0x3FFFFFFF;
vector<pii> G[MAXN]; // 邻接表表示无向图，保存每个节点的相邻节点及边的权重
int dis[MAXN], ans; // dis数组保存每个节点到已选节点集的距离，ans记录最小生成树的边权和
bool vis[MAXN]; // 标记一个节点是否已经被访问

// Prim算法实现
void Prim(int n, int s) {
	priority_queue<pii, vector<pii>, greater<pii>> que; // 使用优先队列，每次选取距离最小的节点
	for (int i = 1; i <= n; i++) dis[i] = INF; // 初始化所有节点到已选节点集的距离为无穷大
	dis[s] = 0;
	que.push({0, s}); // 将起始节点放入优先队列
	while (!que.empty()) {
		int cur = que.top().second, len = que.top().first; // 获取当前距离最小的节点及距离
		que.pop(); // 将节点从队列中移除
		if (vis[cur]) continue; // 如果节点已访问，跳过该节点
		vis[cur] = true; // 标记节点为已访问
		ans += len; // 累加边权
		for (pii& nd : G[cur]) { // 遍历当前节点的相邻节点
			int to = nd.second, w = nd.first; // 获取相邻节点及边的权重
			if (dis[to] > w) { // 判断是否找到了更短的距离
				dis[to] = w; // 更新距离
				if (!vis[to]) que.push({dis[to], to}); // 如果相邻节点未访问，将其放入优先队列
			}
		}
	}
}

int main() {
	int u, v, w, n, m;
	cin >> n >> m; // 读取输入：节点数n，边数m
	for (int i = 1; i <= m; i++) {
		cin >> u >> v >> w; // 读取边的信息：起始节点u，终止节点v，边的权重w
		G[u].push_back({w, v}); // 将边添加到邻接表
		G[v].push_back({w, u}); // 因为是无向图，需要在两个方向都添加边
	}
    Prim(n, 1); // 执行Prim算法，从节点1开始
	cout << ans; // 输出最小生成树的边权和
	return 0;
}
