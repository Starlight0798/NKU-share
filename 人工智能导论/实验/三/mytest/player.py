import random      
import threading 
from math import log, sqrt    
from time import time       
from copy import deepcopy
from game import SilentGame
from func_timeout import FunctionTimedOut, func_timeout
from concurrent.futures import ThreadPoolExecutor

class RandomPlayer:
    """
    随机玩家, 随机返回一个合法落子位置
    """

    def __init__(self, color):
        """
        玩家初始化
        :param color: 下棋方，'X' - 黑棋，'O' - 白棋
        """
        self.color = color
        

    def random_choice(self, board):
        """
        从合法落子位置中随机选一个落子位置
        :param board: 棋盘
        :return: 随机合法落子位置, e.g. 'A1' 
        """
        # 用 list() 方法获取所有合法落子位置坐标列表
        action_list = list(board.get_legal_actions(self.color))

        # 如果 action_list 为空，则返回 None,否则从中选取一个随机元素，即合法的落子坐标
        if len(action_list) == 0:
            return None
        else:
            return random.choice(action_list)

    def get_move(self, board):
        """
        根据当前棋盘状态获取最佳落子位置
        :param board: 棋盘
        :return: action 最佳落子位置, e.g. 'A1'
        """
        if self.color == 'X':
            player_name = '黑棋'
        else:
            player_name = '白棋'
        # print("请等一会，对方 {}-{} 正在思考中...".format(player_name, self.color))
        action = self.random_choice(board)
        return action

class HumanPlayer:
    """
    人类玩家
    """

    def __init__(self, color):
        """
        玩家初始化
        :param color: 下棋方，'X' - 黑棋，'O' - 白棋
        """
        self.color = color
    

    def get_move(self, board):
        """
        根据当前棋盘输入人类合法落子位置
        :param board: 棋盘
        :return: 人类下棋落子位置
        """
        # 如果 self.color 是黑棋 "X",则 player 是 "黑棋"，否则是 "白棋"
        if self.color == "X":
            player = "黑棋"
        else:
            player = "白棋"

        # 人类玩家输入落子位置，如果输入 'Q', 则返回 'Q'并结束比赛。
        # 如果人类玩家输入棋盘位置，e.g. 'A1'，
        # 首先判断输入是否正确，然后再判断是否符合黑白棋规则的落子位置
        while True:
            action = input(
                    "请'{}-{}'方输入一个合法的坐标(e.g. 'D3'，若不想进行，请务必输入'Q'结束游戏。): ".format(player,
                                                                                 self.color))

            # 如果人类玩家输入 Q 则表示想结束比赛
            if action == "Q" or action == 'q':
                return "Q"
            else:
                row, col = action[1].upper(), action[0].upper()

                # 检查人类输入是否正确
                if row in '12345678' and col in 'ABCDEFGH':
                    # 检查人类输入是否为符合规则的可落子位置
                    if action in board.get_legal_actions(self.color):
                        return action
                else:
                    print("你的输入不合法，请重新输入!")



class RoxannePlayer(object):
    ''' Roxanne 策略 详见 《Analysis of Monte Carlo Techniques in Othello》 '''
    ''' 提出者：Canosa, R. Roxanne canosa homepage. https://www.cs.rit.edu/~rlc/ '''

    def __init__(self, color):
        """
        Roxanne策略初始化
        :param roxanne_table: 从上到下依次按落子优先级排序
        :param color: 执棋方
        """

        self.roxanne_table = [
            ['A1', 'H1', 'A8', 'H8'],
            ['C3', 'F3', 'C6', 'F6'],
            ['C4', 'F4', 'C5', 'F5', 'D3', 'E3', 'D6', 'E6'],
            ['A3', 'H3', 'A6', 'H6', 'C1', 'F1', 'C8', 'F8'],
            ['A4', 'H4', 'A5', 'H5', 'D1', 'E1', 'D8', 'E8'],
            ['B3', 'G3', 'B6', 'G6', 'C2', 'F2', 'C7', 'F7'],
            ['B4', 'G4', 'B5', 'G5', 'D2', 'E2', 'D7', 'E7'],
            ['B2', 'G2', 'B7', 'G7'],
            ['A2', 'H2', 'A7', 'H7', 'B1', 'G1', 'B8', 'G8']
        ]
        self.color = color

    def roxanne_select(self, board):
        """
        采用Roxanne 策略选择落子策略
        :return: 落子策略
        """

        action_list = list(board.get_legal_actions(self.color))
        if len(action_list) == 0:
            return None
        else:
            for move_list in self.roxanne_table:
                random.shuffle(move_list)
                for move in move_list:
                    if move in action_list:
                        return move

    def get_move(self, board):
        """
        采用Roxanne 策略进行搜索
        :return: 落子
        """

        if self.color == 'X':
            player_name = '黑棋'
        else:
            player_name = '白棋'
        # print("请等一会，对方 {}-{} 正在思考中...".format(player_name, self.color))
        action = self.roxanne_select(board)
        return action


class TreeNode():
    """
    蒙特卡洛树节点
    """

    def __init__(self, parent, color):
        self.parent = parent
        self.w = 0
        self.n = 0
        self.color = color
        self.child = dict()

class AIPlayer:
    """
    AI 玩家
    """

    def __init__(self, color, time_limit = 5, c_param = sqrt(2)):
        """
        玩家初始化
        :param color: 下棋方，'X' - 黑棋，'O' - 白棋
        """
        self.c_param = c_param
        self.time_limit = time_limit
        self.tick = 0
        self.sim_black = RoxannePlayer('X')
        self.sim_white = RoxannePlayer('O')
        self.color = color

    def mcts(self, board):
        """
        蒙特卡洛树搜索，在时间限制范围内，拓展节点搜索结果
        :return: 选择最佳拓展
        """

        root = TreeNode(None, self.color)

        # 设定一个时间停止计算，限定规模
        while time() - self.tick < self.time_limit:
            sim_board = deepcopy(board)
            choice = self.select(root, sim_board)
            self.expand(choice, sim_board)
            winner, diff = self.simulate(choice, sim_board)
            back_score = [1, 0, 0.5][winner]
            if choice.color == 'X':
                back_score = 1 - back_score
            self.back_prop(choice, back_score)

        best_n = -1
        best_move = None
        for k in root.child.keys():
            if root.child[k].n > best_n:
                best_n = root.child[k].n
                best_move = k
        return best_move

    def select(self, node, board):
        """
        蒙特卡洛树搜索，节点选择
        :return: 搜索树向下递归选择子节点
        """

        if len(node.child) == 0:
            return node
        else:
            best_score = -1
            best_move = None
            for k in node.child.keys():
                if node.child[k].n == 0:
                    best_move = k
                    break
                else:
                    N = node.n
                    n = node.child[k].n
                    w = node.child[k].w
                    # 随着访问次数的增加，加号后面的值越来越小，因此我们的选择会更加倾向于选择那些还没怎么被统计过的节点
                    # 避免了蒙特卡洛树搜索会碰到的陷阱——一开始走了歪路。
                    score = w / n + self.c_param * sqrt(log(N) / n)
                    if score > best_score:
                        best_score = score
                        best_move = k
            board._move(best_move, node.color)
            return self.select(node.child[best_move], board)

    def expand(self, node, board):
        """
        蒙特卡洛树搜索，节点扩展
        """
        op_color = 'O' if node.color == 'X' else 'X'
        for move in board.get_legal_actions(node.color):
            node.child[move] = TreeNode(node, op_color)

    def simulate(self, node, board):
        """
        蒙特卡洛树搜索，采用Roxanne策略代替随机策略搜索，模拟扩展搜索树
        """

        if node.color == 'O':
            current_player = self.sim_black
        else:
            current_player = self.sim_white
        sim_game = SilentGame(self.sim_black, self.sim_white, board, current_player)
        return sim_game.run()

    def back_prop(self, node, score):
        """
        蒙特卡洛树搜索，反向传播，回溯更新模拟路径中的节点奖励
        """
        node.n += 1
        node.w += score
        if node.parent is not None:
            self.back_prop(node.parent, 1 - score)
    
    def get_move(self, board):
        """
        根据当前棋盘状态获取最佳落子位置
        :param board: 棋盘
        :return: action 最佳落子位置, e.g. 'A1'
        """
        self.tick = time()
        if self.color == 'X':
            player_name = '黑棋'
        else:
            player_name = '白棋'
        # print("请等一会，对方 {}-{} 正在思考中...".format(player_name, self.color))
        # -----------------请实现你的算法代码--------------------------------------
        action = self.mcts(deepcopy(board))
        # ------------------------------------------------------------------------
        return action
    

class Node:
    def __init__(self, board, parent, color, action):
        self.parent = parent # 父节点
        self.children = [] # 子节点列表
        self.visit_times = 0 # 访问次数
        self.board = board # 游戏选择这个Node的时的棋盘
        self.color = color # 当前玩家
        self.prevAction = action # 到达这个节点的action
        self.unvisitActions = list(board.get_legal_actions(color)) # 未访问过的actions
        self.isover = self.gameover(board) # 是否结束了
        if (self.isover == False) and (len(self.unvisitActions) == 0): # 没得走了但游戏还没结束
            self.unvisitActions.append("noway")

        self.reward = {'X': 0, 'O': 0}
        self.bestVal = {'X': 0, 'O': 0}

    def gameover(self, board):
        l1 = list(board.get_legal_actions('X'))
        l2 = list(board.get_legal_actions('O'))
        return len(l1)==0 and len(l2)==0

    def calcBestVal(self, balance, color):
        if self.visit_times==0:
            print("-------------------------")
            print("oops!visit_times==0!")
            self.board.display()
            print("-------------------------")
        self.bestVal[color] = self.reward[color] / self.visit_times + balance * sqrt(2 * log(self.parent.visit_times) / self.visit_times)
    
    
class MonteCarlo:
    def __init__(self, time_limit=10, c_param=sqrt(2)):
        self.time_limit = time_limit
        self.c_param = c_param
    # uct方法的实现
    # return: action(string)
    
    def search(self, board, color): 
        # board: 当前棋局
        # color: 当前玩家

        # 特殊情况：只有一种选择
        actions=list(board.get_legal_actions(color))
        if len(actions) == 1:
            return list(actions)[0]

        # 创建根节点
        newboard = deepcopy(board)
        root = Node(newboard, None, color, None)

        # 考虑时间限制        
        try:
            # 测试程序规定每一步在60s以内
            func_timeout(self.time_limit, self.whileFunc, args=[root]) 
        except FunctionTimedOut:
            pass

        return self.best_child(root, self.c_param, color).prevAction

    
    def whileFunc(self, root):
        while True:
            # mcts four steps
            # selection,expantion
            expand_node = self.tree_policy(root)
            # simulation
            reward = self.default_policy(expand_node.board, expand_node.color)
            # Backpropagation
            self.backup(expand_node, reward)        

    def expand(self, node):
        """ 
        输入一个节点，在该节点上拓展一个新的节点，使用random方法执行Action，返回新增的节点 
        """

        action = random.choice(node.unvisitActions)
        node.unvisitActions.remove(action)

        # 执行action，得到新的board
        newBoard = deepcopy(node.board)
        if action != "noway":
            newBoard._move(action, node.color)
        else:
            pass

        newColor = 'X' if node.color=='O' else 'O'
        newNode = Node(newBoard,node,newColor,action)
        node.children.append(newNode)

        return newNode
    
    def best_child(self, node, balance, color):
        # 对每个子节点调用一次计算bestValue
        for child in node.children:
            child.calcBestVal(balance, color)

        # 对子节点按照bestValue排序，降序
        sortedChildren = sorted(node.children, key=lambda x: x.bestVal[color], reverse = True)

        # 返回bestValue最大的元素
        return sortedChildren[0]

    def tree_policy(self, node):
        """
        传入当前需要开始搜索的节点（例如根节点）
        根据exploration/exploitation算法返回最好的需要expend的节点
        注意如果节点是叶子结点直接返回。
        """
        retNode = node
        while not retNode.isover:
            if len(retNode.unvisitActions)>0:
                # 还有未展开的节点
                return self.expand(retNode)
            else:
                # 选择val最大的
                retNode = self.best_child(retNode, sqrt(2), retNode.color)

        return retNode

    def default_policy(self, board, color):
        """
        蒙特卡罗树搜索的Simulation阶段
        输入一个需要expand的节点，随机操作后创建新的节点，返回新增节点的reward。
        注意输入的节点应该不是子节点，而且是有未执行的Action可以expend的。

        基本策略是随机选择Action。
        """
        newBoard = deepcopy(board)
        newColor = color

        def gameover(board):
            l1 = list(board.get_legal_actions('X'))
            l2 = list(board.get_legal_actions('O'))
            return len(l1)==0 and len(l2)==0

        while not gameover(newBoard):
            actions = list(newBoard.get_legal_actions(newColor))
            if len(actions) == 0:
                action = None
            else:
                action = random.choice(actions)
            
            if action is None:
                pass
            else:
                newBoard._move(action, newColor)
            
            newColor = 'X' if newColor=='O' else 'O'
        
        # 0黑 1白 2平局
        winner, diff = newBoard.get_winner()
        diff /= 64
        return winner, diff

    def backup(self, node, reward):
        newNode = node
        # 节点不为None时
        while newNode is not None:
            newNode.visit_times += 1

            if reward[0] == 0:
                newNode.reward['X'] += reward[1]
                newNode.reward['O'] -= reward[1]
            elif reward[0] == 1:
                newNode.reward['X'] -= reward[1]
                newNode.reward['O'] += reward[1]
            elif reward[0] == 2:
                pass

            newNode = newNode.parent

class AIPlayer2:
    """
    AI 玩家
    """

    def __init__(self, color, time_limit=10, c_param=sqrt(2)):
        """
        玩家初始化
        :param color: 下棋方，'X' - 黑棋，'O' - 白棋
        """
        self.time_limit = time_limit
        self.color = color
        self.c_param = c_param

    def get_move(self, board):
        """
        根据当前棋盘状态获取最佳落子位置
        :param board: 棋盘
        :return: action 最佳落子位置, e.g. 'A1'
        """
        if self.color == 'X':
            player_name = '黑棋'
        else:
            player_name = '白棋'
        # print("请等一会，对方 {}-{} 正在思考中...".format(player_name, self.color))

        # -----------------请实现你的算法代码--------------------------------------

        mcts = MonteCarlo(self.time_limit, self.c_param)
        action = mcts.search(board, self.color)
        # action = UCT_Search.UCTSearch(board, self.color)
        # ------------------------------------------------------------------------

        return action
    
class AIPlayer3:
    """
    AI 玩家
    """

    def __init__(self, color, time_limit = 5, c_param = sqrt(2), num_threads=4):
        """
        玩家初始化
        :param color: 下棋方，'X' - 黑棋，'O' - 白棋
        """
        self.c_param = c_param
        self.time_limit = time_limit
        self.tick = 0
        self.sim_black = RoxannePlayer('X')
        self.sim_white = RoxannePlayer('O')
        self.color = color
        self.num_threads = num_threads
        
    def parallel_mcts(self, board):
        results = []
        with ThreadPoolExecutor(max_workers=self.num_threads) as executor:
            futures = [executor.submit(self.mcts, deepcopy(board)) for _ in range(self.num_threads)]
            for future in futures:
                results.append(future.result())

        return self.vote_best_move(results)

    def vote_best_move(self, moves):
        move_count = {}
        for move in moves:
            if move not in move_count:
                move_count[move] = 0
            move_count[move] += 1

        return max(move_count, key=move_count.get)

    def mcts(self, board):
        """
        蒙特卡洛树搜索，在时间限制范围内，拓展节点搜索结果
        :return: 选择最佳拓展
        """

        root = TreeNode(None, self.color)

        # 设定一个时间停止计算，限定规模
        while time() - self.tick < self.time_limit:
            sim_board = deepcopy(board)
            choice = self.select(root, sim_board)
            self.expand(choice, sim_board)
            winner, diff = self.simulate(choice, sim_board)
            back_score = [1, 0, 0.5][winner]
            if choice.color == 'X':
                back_score = 1 - back_score
            self.back_prop(choice, back_score)

        best_n = -1
        best_move = None
        for k in root.child.keys():
            if root.child[k].n > best_n:
                best_n = root.child[k].n
                best_move = k
        return best_move

    def select(self, node, board):
        """
        蒙特卡洛树搜索，节点选择
        :return: 搜索树向下递归选择子节点
        """

        if len(node.child) == 0:
            return node
        else:
            best_score = -1
            best_move = None
            for k in node.child.keys():
                if node.child[k].n == 0:
                    best_move = k
                    break
                else:
                    N = node.n
                    n = node.child[k].n
                    w = node.child[k].w
                    # 随着访问次数的增加，加号后面的值越来越小，因此我们的选择会更加倾向于选择那些还没怎么被统计过的节点
                    # 避免了蒙特卡洛树搜索会碰到的陷阱——一开始走了歪路。
                    score = w / n + self.c_param * sqrt(log(N) / n)
                    if score > best_score:
                        best_score = score
                        best_move = k
            board._move(best_move, node.color)
            return self.select(node.child[best_move], board)

    def expand(self, node, board):
        """
        蒙特卡洛树搜索，节点扩展
        """
        op_color = 'O' if node.color == 'X' else 'X'
        for move in board.get_legal_actions(node.color):
            node.child[move] = TreeNode(node, op_color)

    def simulate(self, node, board):
        """
        蒙特卡洛树搜索，采用Roxanne策略代替随机策略搜索，模拟扩展搜索树
        """

        if node.color == 'O':
            current_player = self.sim_black
        else:
            current_player = self.sim_white
        sim_game = SilentGame(self.sim_black, self.sim_white, board, current_player)
        return sim_game.run()

    def back_prop(self, node, score):
        """
        蒙特卡洛树搜索，反向传播，回溯更新模拟路径中的节点奖励
        """
        node.n += 1
        node.w += score
        if node.parent is not None:
            self.back_prop(node.parent, 1 - score)
    
    def get_move(self, board):
        self.tick = time()
        if self.color == 'X':
            player_name = '黑棋'
        else:
            player_name = '白棋'
        print("请等一会，对方 {}-{} 正在思考中...".format(player_name, self.color))
        
        action = self.parallel_mcts(deepcopy(board))
        
        return action