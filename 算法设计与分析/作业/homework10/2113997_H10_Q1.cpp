#include <bits/stdc++.h>
using namespace std;

// 定义搜索树节点结构体
struct Node {
    int lv; // 当前层级
    vector<int> assign; // 分配的课程
    int tt; // 总备课时间
    int lb; // 最优边界
    bool operator<(const Node &other) const {
        return lb > other.lb;
    }
};

// 检查课程是否已经分配过
bool check(const Node &node, int course){
    for (size_t i = 0; i < node.assign.size(); i++) {
        if (node.assign[i] == course) {
            return false;
        }
    }
    return true;
}

// 计算最优边界的函数
// 最优边界Lb = 已分配任务的代价 + 剩余未分配任务中最小的代价
int calc_lb(const Node &node, const vector<vector<int>> &prep_time) {
    int min_time = 0;
    for (size_t t = node.lv; t < prep_time.size(); t++) {
        int min_t = INT_MAX;
        for (size_t c = 0; c < prep_time.size(); c++) {
            if (check(node, c)) { //已经分配过的课程不再计算
                min_t = min(min_t, prep_time[t][c]);
            }
        }
        min_time += min_t;
    }
    return node.tt + min_time;
}

int main() {
    // 备课时间数据
    vector<vector<int>> prep_time = {
        {2, 10, 9, 7},
        {15, 4, 14, 8},
        {13, 14, 16, 11},
        {4, 15, 13, 9},
    };

    int n = prep_time.size();

    // 优先队列，按最优边界升序
    priority_queue<Node> pq;
    Node root{0, vector<int>(n, -1), 0, 0};
    root.lb = calc_lb(root, prep_time);
    pq.push(root);
    int min_time = INT_MAX;
    vector<int> best_assign;

    // 分支限界搜索
    while (!pq.empty()) {
        Node cur = pq.top();
        pq.pop();

        // 到达叶子节点，更新最优解
        if (cur.lv == n) {
            if (cur.tt < min_time) {
                min_time = cur.tt;
                best_assign = cur.assign;
            }
            continue;
        }

        // 扩展子节点
        for (int c = 0; c < n; c++) {
            if (check(cur, c)) {
                Node nxt = cur;
                nxt.lv++;
                nxt.assign[cur.lv] = c;
                nxt.tt += prep_time[cur.lv][c];
                nxt.lb = calc_lb(nxt, prep_time);
                if (nxt.lb < min_time) {
                    pq.push(nxt);
                }
            }
        }
    }

    // 输出结果
    cout << "最小备课时间: " << min_time << endl;
    cout << "课程分配: " << endl;
    for (int i = 0; i < n; i++) {
        cout << "教师" << char('A' + i) << " -> 课程" << best_assign[i] + 1 << endl;
    }
    cout << endl;
    return 0;
}
