#include <bits/stdc++.h>
#define pii pair<int, int>
#define MAXN 10000
using namespace std;

pii lecture[MAXN];

int main(){
    priority_queue<int, vector<int>, greater<int>> room;  // 用小根堆存储每个教室的结束时间
    int n;
    cin >> n;  // 输入讲座数量
    for(int i = 0; i < n; i++) cin >> lecture[i].first >> lecture[i].second;  // 输入每个讲座的开始时间和结束时间
    sort(lecture, lecture + n); //将讲座按照开始时间排序
    room.push(lecture[0].second);  // 将第一个讲座安排在一个教室中
    for(int i = 1; i < n; i++){
        int min_end_time = room.top();  // 获取当前可用教室中最早的结束时间
        int start = lecture[i].first, end = lecture[i].second;  // 获取当前讲座的开始时间和结束时间
        if(start >= min_end_time) room.pop();  // 如果当前讲座可以安排在当前可用教室中，则将可用教室弹出
        room.push(end);  // 将当前讲座安排在某个教室中
    }
    cout << room.size();  // 输出所需教室数
    return 0;
}
