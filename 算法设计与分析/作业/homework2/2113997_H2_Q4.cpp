#include <bits/stdc++.h>
using namespace std;

//定义一个点结构体
struct Point{
    int x;
    int y;
    Point(int a=0, int b=0):x(a),y(b){} 
};

//计算两点之间的距离平方
int dis(const Point& a, const Point& b){
    int dx = a.x - b.x;
    int dy = a.y - b.y;
    return dx * dx + dy * dy;
}

int main(){
    int lens, mdis = 0x7FFFFFFF; //lens表示点数，mdis表示目前找到的最小距离的平方
    cin>>lens;
    Point p[lens],a,b; //定义一个点数组
    cin>>p[0].x>>p[0].y; //读入第一个点
    //从第二个点开始读入，并且寻找最小距离的平方所对应的两个点
    for(int i=1;i<lens;i++){
        cin>>p[i].x>>p[i].y;
        for(int j=0;j<i;j++){
            int disij = dis(p[i],p[j]); //计算i和j两点之间的距离平方
            if(disij < mdis){ //如果小于当前找到的最小距离平方
                mdis = disij; //更新最小距离平方
                b = p[i]; //更新b点
                a = p[j]; //更新a点
            }
        }
    }
    printf("(%d,%d),(%d,%d)",a.x,a.y,b.x,b.y); //输出最小距离所对应的两个点
    return 0;
}
