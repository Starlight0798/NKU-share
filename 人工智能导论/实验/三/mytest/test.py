from game import Game
from player import HumanPlayer, RandomPlayer, AIPlayer, AIPlayer2, AIPlayer3
    
if __name__ == '__main__':
    
    player1 = AIPlayer("X", time_limit = 0.5)
    player2 = AIPlayer3("O", time_limit = 0.5)
    game = Game(player1, player2)
    game.run()