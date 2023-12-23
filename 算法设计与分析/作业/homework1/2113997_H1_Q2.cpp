#include <iostream>
using namespace std;

int main(){
    int n, m, a, b;
    cin>>n>>m>>a>>b; // 读入四个整数，n 为需要乘坐的次数，a 为单程票价，b 为 m 次乘车票价
    if(double(b)/m>=a){ // 如果 b/m>=a，那么买单程票更划算
        cout<<n*a; // 输出单程票的花费
        return 0;
    }
    int x = n/m, y = n%m; // 计算需要购买 m 次乘车票和单程票的数量，x 为购买 m 次乘车票的张数，y 为购买单程票的张数
    cout<<(b*x + a*y); // 输出最小花费
    return 0;
}
