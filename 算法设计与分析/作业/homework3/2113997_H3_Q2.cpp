#include <bits/stdc++.h>   
#define MAXN 10000          //定义最大节点数为10000
using namespace std;

vector<int> G[MAXN];        //定义邻接表G
bool vis[MAXN];             //定义标记数组vis

void bfs(int s){            //广度优先搜索函数
    queue<int> que;         //定义队列，将起点放入队列中
    que.push(s);
    while(!que.empty()){    
        int cur = que.front();  
        que.pop();              
        if(vis[cur]) continue;  //如果该节点已经被访问过，跳过本次循环
        vis[cur] = true;        //标记该节点已被访问过
        cout<<cur<<" ";         
        for(int& to:G[cur]){    //遍历该节点所有邻接节点
            if(!vis[to]) que.push(to); //如果邻接节点未被访问过，将其入队
        }
    }
}

void dfs(int s){            //深度优先搜索函数
    cout<<s<<" ";           //输出该节点
    vis[s] = true;          //标记该节点已被访问过
    for(int& to:G[s]){      //遍历该节点所有邻接节点
        if(!vis[to]) dfs(to);   //如果邻接节点未被访问过，递归搜索
    }
}

int main(){             
    int n, m, s, u, v;      
    cin>>n>>m>>s;       //输入节点数，边数和起点
    for(int i=0;i<m;i++){       //输入边的两个端点
        cin>>u>>v;
        G[u].push_back(v);      //建立无向边
        G[v].push_back(u);
    }
    for(int i=0;i<n;i++){       //对于每个节点，将邻接节点排序
        sort(G[i].begin(), G[i].end());
    }
    bfs(s); cout<<endl;     //进行广度优先搜索
    memset(vis, false, sizeof(vis));    //将标记数组初始化为false
    dfs(s);                 //进行深度优先搜索
    return 0;
}
