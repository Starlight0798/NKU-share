n = int(input())
men_prefs = {}
women_prefs = {}

# 读入每个男性的偏好列表
for i in range(n):
    line = input().split(":")
    man = line[0]
    prefs = line[1].split(">")
    men_prefs[man] = prefs

# 读入每个女性的偏好列表
for i in range(n):
    line = input().split(":")
    woman = line[0]
    prefs = line[1].split(">")
    women_prefs[woman] = prefs

free_men = list(men_prefs.keys())  # 所有男性都是自由的
matches = {}  # 存储匹配结果的字典

while free_men:
    man = free_men[0]
    woman = men_prefs[man][0]

    if woman not in matches:  # 女性是自由的
        matches[woman] = man
        free_men.pop(0)
    else:  # 女性已经有配偶了
        current_man = matches[woman]
        if women_prefs[woman].index(man) < women_prefs[woman].index(current_man):
            matches[woman] = man
            free_men.pop(0)
            free_men.append(current_man)
        else:
            men_prefs[man].pop(0)

# 输出匹配结果
for woman, man in matches.items():
    print("({}, {})".format(man, woman))
