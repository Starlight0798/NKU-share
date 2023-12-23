#include <bits/stdc++.h>
using namespace std;

// 物品结构体
struct Item {
    int value, weight; // 价值和重量
    double value_weight_ratio; // 价值-重量比
};

// 搜索树节点结构体
struct Node {
    int level; // 当前节点所在层级
    int value; // 已选择物品总价值
    int weight; // 已选择物品总重量
    double ub; // 上界
    bool operator<(const Node &other) const { // 重载<运算符，用于优先队列排序
        return ub < other.ub;
    }
};

// 按价值-重量比降序排序函数
bool cmp(const Item &a, const Item &b) {
    return a.value_weight_ratio > b.value_weight_ratio;
}

// 计算上界函数
double get_ub(int level, int weight, int value, int capacity, vector<Item> &items) {
    if (weight >= capacity) {
        return value;
    }
    double max_ratio = 0;
    for (size_t i = level + 1; i < items.size(); i++) {
        max_ratio = max(max_ratio, items[i].value_weight_ratio);
    }
    double ub = value + (capacity - weight) * max_ratio;
    return ub;
}


// 0-1背包问题求解函数
int knapsack(int capacity, vector<Item> &items) {
    // 根据价值-重量比排序物品
    sort(items.begin(), items.end(), cmp);
    int n = items.size();
    int max_value = 0; // 记录最大价值
    priority_queue<Node> pq; // 优先队列，按上界降序排序

    // 初始化根节点
    Node root;
    root.level = -1;
    root.value = 0;
    root.weight = 0;
    root.ub = get_ub(root.level, root.weight, root.value, capacity, items);
    pq.push(root);

    // 分支限界搜索
    while (!pq.empty()) {
        Node current = pq.top();
        pq.pop();

        // 如果当前节点是叶子节点，跳过
        if (current.level == n - 1) continue;

        // 处理左子节点（选择当前物品）
        Node left = current;
        left.level++;
        left.weight += items[left.level].weight;
        left.value += items[left.level].value;
        left.ub = get_ub(left.level, left.weight, left.value, capacity, items);

        // 如果左子节点满足背包容量限制
        if (left.weight <= capacity) {
            // 更新最大价值
            if (left.value > max_value) {
                max_value = left.value;
            }
            // 如果左子节点上界大于当前最大价值，加入优先队列
            if (left.ub > max_value) {
                pq.push(left);
            }
        }

        // 处理右子节点（不选择当前物品）
        Node right = current;
        right.level++;
        right.ub = get_ub(right.level, right.weight, right.value, capacity, items);

        // 如果右子节点上界大于当前最大价值，加入优先队列
        if (right.ub > max_value) {
            pq.push(right);
        }
    }
    return max_value;
}

int main() {
    int capacity, n;
    vector<Item> items;
    printf("请输入背包容量: ");
    scanf("%d", &capacity);
    printf("请输入物品数量: ");
    scanf("%d", &n);
    printf("请依次输入物品信息: \n");
    for(int i = 0; i < n; i++){
        int w, v; 
        double r;
        printf("-----物品%d-----\n", i+1);
        printf("价值: "); scanf("%d", &v);
        printf("重量: "); scanf("%d", &w);
        r = v / w;
        items.push_back({v, w, r});
    }
    int max_value = knapsack(capacity, items);
    cout << "最大价值为: " << max_value << endl;
    return 0;
}
