#include <bits/stdc++.h>
using namespace std;

// 数组a和数组b的长度
int lena, lenb;

// 合并两个有序数组
void merge(int* a, int* b, int* c) {
    // 定义三个指针，分别指向数组a、数组b和数组c
    int pa = 0, pb = 0, pc = 0;
    while (pc < lena + lenb) {
        // 如果数组a已经被扫描完，或者数组b的当前元素比数组a的当前元素小，
        // 则将数组b的当前元素加入数组c，并将指向数组b的指针pb加1
        if (pa >= lena || (pb < lenb && a[pa] >= b[pb])) {
            c[pc++] = b[pb];
            pb++;
        }
        // 否则，将数组a的当前元素加入数组c，并将指向数组a的指针pa加1
        else if (pb >= lenb || (pa < lena && a[pa] <= b[pb])) {
            c[pc++] = a[pa];
            pa++;
        }
    }
}

int main() {
    // 读入数组a和数组b的长度
    cin >> lena >> lenb;

    // 定义数组a和数组b，并读入它们的元素
    int a[lena], b[lenb];
    for (int i = 0; i < lena; i++) cin >> a[i];
    for (int i = 0; i < lenb; i++) cin >> b[i];

    // 数组c用于存放合并后的有序数组
    int c[lena + lenb];

    // 调用merge函数，将数组a和数组b合并为数组c
    merge(a, b, c);
    for (int i = 0; i < lena + lenb; i++) cout << c[i] << " ";

    return 0;
}
