from kanren import run, eq, membero, var, conde        # kanren一个描述性Python逻辑编程系统
from kanren.core import lall                           # lall包用于定义规则
import time

###############################################################################
####             可在此处定义自己所需要用到的自定义函数(可选)                  #### 
####   提示：定义左邻近规则left(), 定义右邻近规则right(),定义邻近规则next()    ####
###############################################################################
#                                                                             #
def left(q, p, list):
    return membero((q, p), zip(list, list[1:]))


def next(q, p, list):  # p q 相邻意味着要么p在q左边，要么q在p左边
    return conde([left(q, p, list)], [left(p, q, list)])

#                                                                             #
###############################################################################
#################                非必要性工作                 ################## 
###############################################################################

class Agent:
    """
    推理智能体.
    """
    
    def __init__(self):
        """
        智能体初始化.
        """
        
        self.units = var()              # 单个unit变量指代一座房子的信息(国家，工作，饮料，宠物，颜色) 
                                        # 例如('英国人', '油漆工', '茶', '狗', '红色')即为正确格式，但不是本题答案
                                        # 请基于给定的逻辑提示求解五条正确的答案
        self.rules_zebraproblem = None  # 用lall包定义逻辑规则
        self.solutions = None           # 存储结果
        
    def define_rules(self):
        """
        定义逻辑规则.
        """

        self.rules_zebraproblem = lall(
            (eq, (var(), var(), var(), var(), var()), self.units),         # self.units共包含五个unit成员，即每一个unit对应的var都指代一座房子(国家，工作，饮料，宠物，颜色) 
                                                                           # 各个unit房子又包含五个成员属性: (国家，工作，饮料，宠物，颜色)
            
            ##############################################################################
            ####               请在以下区域中添加逻辑规则，感受逻辑约束问题               #### 
            ####     输出：五条房子匹配信息('英国人', '油漆工', '茶', '狗', '红色')       ####
            ##############################################################################
            #                                                                            #
            
            # 示例：基于问题信息可以提炼出，有人养斑马，有人喜欢和矿泉水等信息
            (membero, ('英国人', var(), var(), var(), '红色'), self.units),  # 英国人住在红房子里
            (membero, ('西班牙人', var(), var(), '狗', var()), self.units),  # 西班牙人养了一条狗
            (membero, ('日本人', '油漆工', var(), var(), var()), self.units),  # 日本人是一个油漆工
            (membero, ('意大利人', var(), '茶', var(), var()), self.units),  # 意大利人喝茶。
            (eq, (('挪威人', var(), var(), var(), var()), var(), var(), var(), var()), self.units),  # 挪威人住在左边的第一个房子里
            
            (left, # 绿房子在白房子的右边 
            (var(), var(), var(), var(), '绿色'),
            (var(), var(), var(), var(), '白色'),
            self.units),
            
            (membero, (var(), '摄影师', var(), '蜗牛', var()), self.units),  # 摄影师养了一只蜗牛
            (membero, (var(), '外交官', var(), var(), '黄色'), self.units),  # 外交官住在黄房子里
            (eq, (var(), var(),(var(), var(), '牛奶', var(), var()),var(), var()), self.units),  # 中间那个房子的人喜欢喝牛奶
            (membero, (var(), var(), '咖啡', var(), '绿色'), self.units),  # 喜欢喝咖啡的人住在绿房子里
            
            (next, ('挪威人', var(), var(), var(), var()),
            (var(), var(), var(), var(), '蓝色'), self.units),  # 挪威人住在蓝房子旁边。
            (membero, (var(), '小提琴家', '橘子汁', var(), var()), self.units),  # 小提琴家喜欢喝橘子汁

            (next, (var(), '医生', var(), var(), var()),  # 养狐狸的人所住的房子与医生的房子相邻
            (var(), var(), var(), '狐狸', var()), self.units),

            (next, (var(), '外交官', var(), var(), var()),  # 养马的人所住的房子与外交官的房子相邻
            (var(), var(), var(), '马', var()), self.units),

            (membero, (var(), var(), var(), '斑马', var()), self.units),  # 有人养斑马
            (membero, (var(), var(), '矿泉水', var(), var()), self.units) # 有人喝水

            #                                                                            #
            ##############################################################################
            #################             完成后请记得提交作业             ################# 
            ##############################################################################

        )
    
    def solve(self):
        """
        规则求解器(请勿修改此函数).
        return: 斑马规则求解器给出的答案，共包含五条匹配信息，解唯一.
        """
        
        self.define_rules()
        self.solutions = run(0, self.units, self.rules_zebraproblem)
        return self.solutions


agent = Agent()
solutions = agent.solve()

# 提取解释器的输出
output = [house for house in solutions[0] if '斑马' in house][0][4]
print ('\n{}房子里的人养斑马'.format(output))
output = [house for house in solutions[0] if '矿泉水' in house][0][4]
print ('{}房子里的人喜欢喝矿泉水'.format(output))

# 解释器的输出结果展示
for i in solutions[0]:
    print(i)