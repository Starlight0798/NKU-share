#include <bits/stdc++.h>
using namespace std;
struct node
{
    double x;
    double y;
};
bool cmpx(node a, node b) // 自定义sort函数排序方式，按x由小到大
{
    return a.x > b.x;
}
bool cmpy(node a, node b) // 自定义sort函数排序方式，按y由小到大
{
    return a.y > b.y;
}
double dis(node n1, node n2) // 距离函数
{
    return (n1.x - n2.x) * (n1.x - n2.x) + (n1.y - n2.y) * (n1.y - n2.y);
}
pair<node, node> closestpairrec(vector<node> &px, vector<node> &py, int l, int r) // l和r分别是p数组的左右端点
{
    if (r - l + 1 <= 3) // 当点对数小于三，直接遍历找到最短点对
    {
        double min = 10000000;
        pair<node, node> res;
        for (int i = l; i <= r; i++)
        {
            for (int j = i + 1; j <= r; j++)
            {
                double t = dis(px[i], px[j]);
                if (t < min) // 更新最小值
                {
                    res.first = px[i];
                    res.second = px[j];
                    min = t;
                }
            }
        }
        return res;
    }
    else
    {
        int mid = (l + r) / 2;
        pair<node, node> resq = closestpairrec(px, py, l, mid);                     // 求出q区域(左半边)内最短点对
        pair<node, node> resr = closestpairrec(px, py, mid + 1, r);                 // 求出r区域(右半边)内最短点对
        pair<node, node> res;                                                       // 保存整个区域最短点对
        double m = min(dis(resq.first, resq.second), dis(resr.first, resr.second)); // 记录左右两区域内最短点对间的距离
        double x = px[mid].x;                                                       // 分界线L
        vector<node> s;
        for (int i = l; i <= r; i++)
        {
            if (abs(px[i].x - x) <= m)
                s.push_back(py[i]);
        } // 生成中间区域s
        double mt = 999999;
        pair<node, node> rest;
        for (int i = 0; i < s.size(); i++)
        {
            for (int j = i + 1; j < s.size() && j - i <= 7; j++) // 遍历每个s中的点及其后面的七个点，来更新最短点最距离
            {
                if (dis(s[i], s[j]) < mt)
                {
                    rest.first = s[i];
                    rest.second = s[j];
                    mt = dis(s[i], s[j]);
                }
            }
        }
        if (mt < m) // 最后三个if来判断最短的是哪部分的点对
            return rest;
        else if (dis(resq.first, resq.second) < dis(resr.first, resr.second))
            return resq;
        else
            return resr;
    }
}

pair<node, node> closestpair(vector<node> &points)
{
    vector<node> px(points), py(points); // 将点对分别按x和y的大小排序
    sort(px.begin(), px.end(), cmpx);
    sort(py.begin(), py.end(), cmpy);
    pair<node, node> res = closestpairrec(px, py, 0, points.size() - 1); // 调用rec函数，找到最短点对
    return res;
}

int main()
{
    int n;
    cin >> n;
    vector<node> p(n);
    for (int i = 0; i < n; i++)
        scanf("%lf%lf", &p[i].x, &p[i].y);
    pair<node, node> result;
    result = closestpair(p);
    printf("%.2lf", dis(result.first, result.second));
    return 0;
}