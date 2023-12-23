#include <bits/stdc++.h>   
#define MAXN 10000          //定义最大节点数为10000
using namespace std;

vector<int> G[MAXN];        //定义邻接表G
int layer[MAXN];            //定义节点到起点的层数

void bfs(int s){            //广度优先搜索函数
    queue<int> que;         //定义队列，将起点放入队列中
    que.push(s);            
    int depth = 0, width = 1;   //定义深度和宽度，深度为0，宽度为1
    while(!que.empty()){    
        for(int i=0;i<width;i++){   //对于每一层中的每一个节点
            int cur = que.front();  
            que.pop();              
            if(layer[cur]!=-1) continue;  //如果该节点已经被访问过，跳过本次循环
            layer[cur] = depth;     //标记该节点层数为depth
            for(int& to:G[cur]){    //遍历该节点所有邻接节点
                if(layer[to]==-1) que.push(to); //如果邻接节点未被访问过，将其入队
            }
        }
        width = que.size();     //更新宽度为队列大小
        depth++;                //更新深度
    }
}

int main(){            
    int n, m, s, u, v;      
    cin>>n>>m>>s;       //输入节点数，边数和起点
    for(int i=0;i<m;i++){     
        cin>>u>>v;
        G[u].push_back(v);      //建立无向边
        G[v].push_back(u);
    }
    memset(layer, -1, sizeof(layer));   //将节点层数数组初始化为-1
    bfs(s);             //进行广度优先搜索
    for(int i=0;i<n;i++){       //输出每个节点到起点的层数
        cout<<layer[i]<<" ";
    }
    return 0;
}
