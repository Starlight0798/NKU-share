import random  
from math import log, sqrt    
from time import time       
from copy import deepcopy
from game import Game
from board import Board

class SilentGame(Game):
    def __init__(self, black_player, white_player, board = Board(), current_player = None):
        super().__init__(black_player, white_player)
        self.board = deepcopy(board) 
        self.current_player = current_player
        
    def run(self):
        winner = None
        diff = -1
        while True:
            self.current_player = self.switch_player(self.black_player, self.white_player)
            color = "X" if self.current_player == self.black_player else "O"
            legal_actions = list(self.board.get_legal_actions(color))
            if len(legal_actions) == 0:
                if self.game_over():
                    winner, diff = self.board.get_winner() 
                    break
                else:
                    continue
            action = self.current_player.get_move(self.board)
            if action is None:
                continue
            else:
                self.board._move(action, color)
                if self.game_over():
                    winner, diff = self.board.get_winner()
                    break
        return winner, diff

class RoxannePlayer(object):
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

    def __init__(self, color, time_limit = 10, c_param = sqrt(2)):
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
        print("请等一会，对方 {}-{} 正在思考中...".format(player_name, self.color))
        # -----------------请实现你的算法代码--------------------------------------
        action = self.mcts(deepcopy(board))
        # ------------------------------------------------------------------------
        return action