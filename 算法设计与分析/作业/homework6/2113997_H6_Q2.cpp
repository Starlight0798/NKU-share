#include <bits/stdc++.h>
#define pii pair<int, int>
#define MAXN 100050
using namespace std;

int pa[MAXN], fre[MAXN]; // pa[i]表示节点i的父节点，fre[i]表示节点i的频率
priority_queue<pii, vector<pii>, greater<pii>> que; // 存储频率的小根堆

int main(){
    int n;
    cin >> n;
    for(int i = 0; i < n;i++){
        cin >> fre[i];
        pa[i] = i; // 初始化每个节点的父节点为它本身
        que.push({fre[i], i}); // 将节点插入小根堆
    }
    int r = n; // 记录新生成的节点编号
    while(que.size() > 1){
        pii n1 = que.top(); // 取出频率最小的节点
        que.pop();
        pii n2 = que.top(); // 取出频率次小的节点
        que.pop();
        pa[n1.second] = pa[n2.second] = pa[r] = r; // 将两个节点和新节点合并
        que.push({n1.first + n2.first, r}); // 将新节点插入小根堆中
        r++; // 更新新节点的编号
    }
    int wl = 0, sumw = 0; // wl表示所有Huffman编码长度之和，sumw表示所有字符频率之和
    for(int i = 0;i < n;i++){
        int cur = i, len = 0;
        while(pa[cur] != cur){ // 不断向上查找父节点，直到根节点为止
            cur = pa[cur];
            len++;
        }
        wl += fre[i] * len; // 计算当前字符的编码长度
        sumw += fre[i]; // 统计所有字符频率之和
    }
    printf("%.2f", double(wl)/sumw); // 输出平均编码长度
    return 0;
}
