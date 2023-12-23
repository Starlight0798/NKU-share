import numpy as np
import copy

class Chessboard:
    def __init__(self, show = True):
        """
        初始化棋盘状态
        """
        
        self.boardInit(show)
    
    def boardInit(self, show = True):
        ''' 
        重置棋盘 
        '''
        
        self.chessboardMatrix = np.zeros((8,8),dtype=np.int8)    #棋盘初始化
        self.unableMatrix = np.zeros((8,8),dtype=np.int8)        #禁止落子位置
        self.queenMatrix = np.zeros((8,8),dtype=np.int8)         #落子位置
        
        printMatrix = np.zeros((9,9),dtype=np.int8)              #棋盘绘制矩阵
        for i in range(8):
            printMatrix[0][i+1] = i
            printMatrix[i+1][0] = i
        self.printMatrix = printMatrix
        if show:
            self.printChessboard()
    
    def trans(self, x):
        ''' 
        棋盘绘制字符转换 
        '''
        
        return{0:'-',-1:'x',1:'o'}.get(x)
    
    def isOnChessboard(self, x,y):
        ''' 
        判断落子是否在棋盘上
        '''
        
        return (x*(7-x) >=0 and y*(7-y) >=0)
        
    def setLegal(self, x, y):
        ''' 
        禁止落子位置指定
        '''
        
        return (self.unableMatrix +1)[x][y]

    def setQueen(self, x, y, show = True):
        '''
        落子之后更新棋盘
        '''
        
        if self.setLegal(x, y):
            self.queenMatrix[x][y] =1                                       #落子位置
            for i in range(8):
                self.unableMatrix[x][i] =-1                                 #本行无法落子
                self.unableMatrix[i][y] =-1                                 #本列无法落子
            for i in range(-7,8):
                if self.isOnChessboard(x+i,y+i):
                    self.unableMatrix[x+i][y+i] =-1                         #正对角线无法落子
                if self.isOnChessboard(x+i,y-i):
                    self.unableMatrix[x+i][y-i] =-1                         #反对角线无法落子
            self.chessboardMatrix = self.unableMatrix +2*self.queenMatrix   #更新棋盘
            self.printMatrix[1:9,1:9] = self.chessboardMatrix
            if show:
                self.printChessboard()
            return True
        else:
            print('落子失败')
            return False
        
    def play(self):
        '''
        玩家互动
        '''
        
        while True:
            action = input("请玩家输入一个合法的坐标(e.g. '2-3'，若想重新开始，请打出'init'，若想退出，请打出'Q'。): ")

            if action == 'init':
                self.boardInit()
                continue
            if action == 'Q' or action == 'q' or action == 'quit' or action == 'QUIT':
                break

            if '-' in action:
                x,y =action.split('-')
            elif ',' in action:
                x,y =action.split(',')
            else:
                x = action[0]
                y = action[-1]
            
            if x.isdigit() and y.isdigit():
                self.setQueen(int(x),int(y))
                if self.isWin():
                    print('Win!')
                    self.printMatrix[1:9,1:9] = self.queenMatrix
                    self.printChessboard()
                    action = input("请玩家输入'Y'进入下一局,输入其它任意值退出: ")
                    if action == 'y' or action == 'Y':
                        self.boardInit()
                        self.Play()
                    else:
                        break
                    
                elif self.isLose():
                    print('Lose!')
                    self.printMatrix[1:9,1:9] = self.queenMatrix
                    self.printChessboard()
                    action = input("请玩家输入'Y'进入下一局,输入其它任意值退出: ")
                    if action == 'y' or action == 'Y':
                        self.boardInit()
                        self.play()
                    else:
                        break
                    
            else:
                print('请输入合法坐标或指定命令.')
        

    def isWin(self):
        '''
        胜利条件判断
        '''
        
        if sum(sum(self.queenMatrix)) ==8:
            return True
        else:
            return False

    def isLose(self):
        '''
        失败条件判断
        '''
        
        if not self.isWin() and sum(sum(self.unableMatrix)) ==-64:
            return True
        else:
            return False

    def printChessboard(self, showALL = True):
        '''
        绘制棋盘
        '''
        
        if showALL:
            Board = self.printMatrix
        else:
            Board = self.printMatrix
            Board[1:9,1:9] = self.queenMatrix
            
        for i in range(9):
            for j in range(9):
                if i+j==0:
                    print('  ', end='')
                elif (i==0 and j!=8) or j==0 :
                    print(str(Board[i][j])+' ', end='')
                elif i==0 and j==8:
                    print(str(Board[i][j])+' ')
                elif j!=8:
                    print(self.trans(Board[i][j])+' ', end='')
                else:
                    print(self.trans(Board[i][j])+' ')