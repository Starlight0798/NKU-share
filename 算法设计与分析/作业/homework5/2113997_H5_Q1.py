# 定义缓存驱逐计划函数
def eviction_schedule(k:int, cache:list, requests:list):
    evict = []  # 初始化驱逐列表
    for i, req in enumerate(requests):  # 遍历请求序列
        if req not in cache:  # 如果请求不在缓存中
            if len(cache) < k:  # 如果缓存未满
                cache.append(req)  # 添加请求到缓存
            else:
                dist = []  # 初始化距离列表
                for x in cache:  # 遍历缓存中的元素
                    divreq = requests[i+1:]  # 获取剩余的请求序列
                    d = divreq.index(x) + 1 if x in divreq else 0x3FFFFFFF  # 计算距离，如果找不到元素，将距离设置为极大值
                    dist.append(d)  # 添加距离到距离列表
                idx_max, dis_max = -1, -1  # 初始化最大距离索引和最大距离值
                for j,d in enumerate(dist):  # 遍历距离列表
                    if d > dis_max :  # 如果当前距离大于最大距离
                        idx_max = j  # 更新最大距离索引
                        dis_max = d  # 更新最大距离值
                    elif d == dis_max :  # 如果当前距离等于最大距离
                        rev_req = requests[i-1::-1]  # 获取当前请求之前的逆序请求序列
                        # 如果两个距离相等的缓存元素都在之前的请求序列中，并且当前元素在之前的序列中的位置大于最大距离索引元素的位置
                        if (cache[j] in rev_req) and (cache[idx_max] in rev_req) and \
                        rev_req.index(cache[j]) > rev_req.index(cache[idx_max]):
                            idx_max = j  # 更新最大距离索引
                            dis_max = d  # 更新最大距离值
                evict.append(cache[idx_max])  # 将需要驱逐的元素添加到驱逐列表
                cache[idx_max] = req  # 用当前请求替换需要驱逐的元素
    return evict  # 返回驱逐列表

# 主函数，处理输入并调用缓存驱逐计划函数
if __name__ == '__main__':
    k, n, s = list(map(int, input().split()))  # 读取输入的缓存大小、初始缓存数量和请求序列长度
    initial_blocks = list(map(int, input().split()))  # 读取输入的初始缓存序列
    requests = list(map(int, input().split()))  # 读取输入的请求序列
    ans = eviction_schedule(k, initial_blocks, requests)
    for i in ans:
        print(i, end = ' ')
