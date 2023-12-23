#include <bits/stdc++.h>
using namespace std;

int nTimeA[25][65][65];
int tNodeTime[25][65][65];
int nCount, tA[25], tB[25], tATime[25], tBTime[25];
int tACount, tBCount;

// 计算每个节点执行 A 任务和 B 任务的最短时间
void calcNodeTimeA() {
    // 遍历所有节点
    for (int n = 1; n <= nCount; ++n) {
        int tempT[2][65][65];
        // 初始化临时数组
        memset(tempT, 31, sizeof(tempT));
        tempT[1][0][0] = tempT[0][0][0] = 0;
        // 遍历所有 A 任务和 B 任务的组合
        for (int i = 0; i <= tACount; ++i) {
            for (int j = 0; j <= tBCount; ++j) {
                // 遍历可能分配给节点 n 的 A 任务数量
                for (int k = 1; k <= i; ++k) {
                    tempT[0][i][j] = min(tempT[0][i][j],
                                  tempT[1][i-k][j] + tATime[n] * k * k + tA[n]);
                }
                // 遍历可能分配给节点 n 的 B 任务数量
                for (int k = 1; k <= j; ++k) {
                    tempT[1][i][j] = min(tempT[1][i][j],
                                  tempT[0][i][j-k] + tBTime[n] * k * k + tB[n]);
                }
                // 将最短时间存储到 nTimeA 数组中
                nTimeA[n][i][j] = min(tempT[0][i][j], tempT[1][i][j]);
            }
        }
    }
}

// 计算前n个节点执行 A 任务和 B 任务的最短时间
void calcTotalNodeTime() {
    // 初始化 tNodeTime 数组
    memset(tNodeTime, 31, sizeof(tNodeTime));
    // 处理第一个节点的情况
    for (int i = 0; i <= tACount; ++i) {
        for (int j = 0; j <= tBCount; ++j) {
            tNodeTime[1][i][j] = nTimeA[1][i][j];
        }
    }
    // 遍历所有节点
    for (int n = 2; n <= nCount; ++n) {
        // 遍历所有 A 任务和 B 任务的组合
        for (int i = 0; i <= tACount; ++i) {
            for (int j = 0; j <= tBCount; ++j) {
                // 遍历可能的任务分配情况
                for (int k = 0; k <= i; ++k) {
                    for (int l = 0; l <= j; ++l) {
                        tNodeTime[n][i][j] = min(tNodeTime[n][i][j],
                                      max(tNodeTime[n-1][k][l], nTimeA[n][i-k][j-l]));
                	}
            	}
        	}
    	}
	}
}

int main() {
	freopen("hpc.in", "r", stdin);
	freopen("hpc.out", "w", stdout);
	// 读入任务数量和节点数量
	scanf("%d%d%d", &tACount, &tBCount, &nCount);
	// 读入每个节点的相关参数
	for (int i = 1; i <= nCount; ++i) {
    	scanf("%d%d%d%d", &tA[i], &tB[i], &tATime[i], &tBTime[i]);
	}
	// 计算每个节点执行任务的最短时间
	calcNodeTimeA();
	// 计算前n个节点执行任务的最短时间
	calcTotalNodeTime();
	// 输出结果
	printf("%d", tNodeTime[nCount][tACount][tBCount]);
	return 0;
}
