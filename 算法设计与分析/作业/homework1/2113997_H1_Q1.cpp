#include <iostream>
#include <map>
using namespace std;

const int MAXN = 1001; // 定义常量，表示人数上限
map<char, int> num; // 建立映射，记录人名对应编号

// 人的结构体
struct person{
    char name; //人名
    char fav[MAXN]; // 喜欢的人，按优先级顺序排列
    char date_to; // 已约会对象
    bool vis[MAXN]; // 是否已被访问过
    // 判断是否所有人都已被访问过
    bool all_vis(int n){
        for(int i=1;i<=n;i++) if(!vis[i]) return false;
        return true;
    }
    // 获取未被访问过的最喜欢的人
    char get_top(int n){
        for(int i=1;i<=n;i++){
            if(vis[i]) continue;
            return fav[i];
        }
        return 0;
    }
    // 判断两个人中谁更受欢迎
    char prefer(int n, char a, char b){
        for(int i=1;i<=n;i++){
            if(fav[i]==a) return a;
            if(fav[i]==b) return b;
        }
        return '#';
    }
    // 构造函数，初始化约会对象为空
    person(){name = date_to = '#';}
}man[MAXN], woman[MAXN];

// 获取当前空闲的男人编号
int get_free_man(int n){
    for(int i=1;i<=n;i++){
        if(man[i].date_to == '#') return i;
    }
    return 0;
}

int main(){
    ios::sync_with_stdio(false); // 关闭同步流，提高cin、cout输入输出效率
    cin.tie(NULL); cout.tie(NULL); // 解除cin、cout的绑定，加快输入输出速度
    int n,i,j;
    char cur,tmp,s;
    cin>>n; // 输入人数
    // 输入男女各自的喜欢列表
    for(i=1;i<=2*n;i++){
        cin>>cur>>s; 
        if(i<=n){
            man[i].name = cur;
            num[cur] = i;
        }
        else{
            woman[i-n].name = cur;
            num[cur] = i - n;
        }
        for(j=1;j<=n;j++){
            cin>>tmp; if(j<n) cin>>s;
            if(i<=n) man[i].fav[j] = tmp; // 将当前喜欢的人存入该男人的喜欢列表中
            else woman[i-n].fav[j] = tmp; // 将当前喜欢的人存入该女人的喜欢列表中
        }
    }
    // 匹配过程
    int fman = get_free_man(n); // 获取当前空闲男人
    char fname = man[fman].name; // 获取当前空闲男人的名字
    while(fman && !man[fman].all_vis(n)){ // 如果还有空闲男人且还有女人未被访问过
        int to = num[man[fman].get_top(n)]; // 获取当前男人的最喜欢的未被访问过的女人
        man[fman].vis[to] = true; // 标记该女士被男士访问过
        if(woman[to].date_to != '#'){ // 如果该女士已经有男士匹配
            char op_name = woman[to].date_to; // 获取该女士当前男友的名字
            char love = woman[to].prefer(n,op_name,fname); // 比较新男友和当前男友的排名
            if(love == fname){ // 如果女士更喜欢新男友
                man[num[op_name]].date_to = '#'; // 将当前男友和该女士解除匹配
                woman[to].date_to = fname; // 将该女士与新男友匹配
                man[fman].date_to = woman[to].name; // 标记当前男人的匹配对象
            }
            else continue; // 如果女士更喜欢当前男友，则不进行匹配
        }
        else{ // 如果该女士还没有男友，则直接匹配
            woman[to].date_to = fname; // 将该女士与新男友匹配
            man[fman].date_to = woman[to].name; // 标记当前男人的匹配对象
        }
        fman = get_free_man(n); // 找到下一个未匹配的男人
        fname = man[fman].name; // 获取下一个未匹配的男人的名字
    }
    // 输出匹配结果
    for(i=1;i<=n;i++) cout<<"("<<man[i].name<<","<<man[i].date_to<<")"<<'\n';
    return 0;
}