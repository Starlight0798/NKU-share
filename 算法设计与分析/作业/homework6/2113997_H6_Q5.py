# -*- coding: utf-8 -*-
import sys

# 计算欧几里得距离
def euclidean_distance(p1, p2):
    return (p1[0] - p2[0]) ** 2 + (p1[1] - p2[1]) ** 2

# 分治查找最近点对
def closest_pair_recursive(points_sorted_x, points_sorted_y):
    if len(points_sorted_x) <= 3:
        # 当点集大小小于等于3时，直接暴力枚举所有点对的距离
        min_distance = sys.float_info.max
        for i in range(len(points_sorted_x)):
            for j in range(i + 1, len(points_sorted_x)):
                distance = euclidean_distance(points_sorted_x[i], points_sorted_x[j])
                if distance < min_distance:
                    min_distance = distance
        return min_distance

    mid = len(points_sorted_x) // 2
    median = points_sorted_x[mid]
    # 分别将点集按x坐标和y坐标排序
    left_points = points_sorted_x[:mid]
    right_points = points_sorted_x[mid:]
    left_points_y = [p for p in points_sorted_y if p in left_points]
    right_points_y = [p for p in points_sorted_y if p in right_points]
    # 分别递归处理左右两个子区间
    min_left = closest_pair_recursive(left_points, left_points_y)
    min_right = closest_pair_recursive(right_points, right_points_y)
    # 计算左右两个子区间的最小距离
    min_distance = min(min_left, min_right)
    # 找出横跨左右两个子区间的点对，并计算它们的距离
    candidates = [p for p in points_sorted_y if abs(p[0] - median[0]) < min_distance]
    for i in range(len(candidates)):
        for j in range(i + 1, min(i + 7, len(candidates))):
            distance = euclidean_distance(candidates[i], candidates[j])
            if distance < min_distance:
                min_distance = distance

    return min_distance

# 计算最近点对的距离
def closest_pair(points):
    points_sorted_x = sorted(points)
    points_sorted_y = sorted(points, key=lambda p: p[1])
    return closest_pair_recursive(points_sorted_x, points_sorted_y)

if __name__ == '__main__':
    n = int(input())
    points = []
    for i in range(n):
        x, y = map(float, input().split())
        points.append((x, y))
    distance = closest_pair(points)
    # 输出结果保留两位小数
    print(f"{distance:.2f}")
