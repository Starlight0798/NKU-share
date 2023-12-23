#include <bits/stdc++.h>  
#define MAXN 10000         // 定义最大节点数
using namespace std;

vector<int> G[MAXN];       // 存储有向图的邻接表
int ind[MAXN];             // 存储每个节点的入度

void Topo(int n){
    priority_queue<int, vector<int>, greater<int>> que;  // 用于存储当前入度为 0 的节点的优先队列
    for(int i=0;i<n;i++){
        if(!ind[i]) que.push(i);  // 把入度为 0 的节点加入队列中
    }
    while(!que.empty()){
        int cur = que.top(); 
        que.pop();
        cout<<cur<<" ";      // 输出该节点
        for(int& to:G[cur]){  // 遍历以该节点为起点的所有边
            if(!--ind[to]) que.push(to);  // 把入度变为 0 的节点加入队列中
        }
    }
}

int main(){
    int n, m, u, v;
    cin>>n>>m;               // 输入节点数和边数
    for(int i=0;i<m;i++){
        cin>>u>>v;           // 输入一条边的起点和终点
        G[u].push_back(v);   // 把边加入有向图中
        ind[v]++;            // 维护每个节点的入度
    }
    Topo(n);                 // 进行拓扑排序
    return 0;
}
