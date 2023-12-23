#include <bits/stdc++.h>
using namespace std;

// 二分查找函数
int binary_search(int* a, int val, int start, int end) {
    // 如果起始下标大于结束下标，则表明没有找到，返回-1
    if (start > end) return -1;
    int mid = (start + end) / 2;
    if (val == a[mid]) return mid;
    // 如果中间值大于要查找的值，则在左半部分继续查找
    else if (val < a[mid]) return binary_search(a, val, start, mid - 1);
    // 如果中间值小于要查找的值，则在右半部分继续查找
    else return binary_search(a, val, mid + 1, end);
}

int main() {
    // 定义一个长度为10的整型数组a和要查找的值x
    int a[10], x;
    for (int i = 0; i < 10; i++) cin >> a[i];
    cin >> x;
    int place = binary_search(a, x, 0, 9);
    cout << place;

    return 0;
}
