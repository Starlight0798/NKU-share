#include <bits/stdc++.h> 
#define MAXN 10000 // 最大点数为 10000
using namespace std;

vector<int> G[MAXN]; // 使用邻接表存储图
int color[MAXN]; // color 数组用于记录每个点的颜色，-1 表示黑色，1 表示白色

bool bfs(int s){ // 定义 bfs 函数，s 表示起点
    queue<int> que; // 队列que用于存储待遍历的节点
    que.push(s); // 将起点加入队列
    color[s] = 1; // 起点染为白色
    while(!que.empty()){ 
        int cur = que.front(); 
        que.pop(); 
        for(int& to:G[cur]){ // 枚举 cur 的所有邻居 to
            if(!color[to]){ // 如果 to 还没有被染色
                color[to] = -color[cur]; // 将 to 染成与 cur 不同的颜色
                que.push(to); // 将 to 加入队列
            }
            else if(color[to] == color[cur]){ // 如果 to 和 cur 的颜色相同，说明不是二分图
                return false; // 返回 false
            }
        }
    }
    return true; // 如果能够遍历完所有节点，说明是二分图，返回 true
}

int main(){
    int n, m, u, v; // n 表示点数，m 表示边数，u, v 表示一条边的两个端点
    cin>>n>>m; // 读入点数和边数
    for(int i=0;i<m;i++){ 
        cin>>u>>v;
        G[u].push_back(v); 
        G[v].push_back(u); 
    }
    bool flag = bfs(1); // 从 1 号点开始 bfs，判断是否是二分图
    if(flag) cout<<"Yes"; // 如果是二分图，输出 Yes
    else cout<<"No"; // 如果不是二分图，输出 No
    return 0; 
}
