from player import AIPlayer, AIPlayer2, AIPlayer3, RandomPlayer
from game import SilentGame

def run_game(ai_black, ai_white, num_games):
    total_wins_black = []
    total_wins_white = []
    winner_name = { 0: '黑方', 1: '白方'}

    for i in range(num_games):
        print('第{}局 : '.format(i+1), end='')
        game = SilentGame(ai_black, ai_white)
        winner, diff = game.run()
        if winner == 2:
            print('和棋')
        else:
            if winner == 0:
                total_wins_black.append(diff)
            else:
                total_wins_white.append(diff)
            print(f'{winner_name[winner]} 获胜, 领先棋子数: {diff}')

    return total_wins_black, total_wins_white


if __name__ == "__main__":
    ai_black = AIPlayer('X', time_limit=0.3)
    ai_white = AIPlayer3('O', time_limit=0.3)
    print('----------------- TEST BEGIN -----------------')
    black_wins, white_wins = run_game(ai_black, ai_white, 50)
    print('------------------ TEST END ------------------')
    print(f'测试结果: {ai_black.color} 胜 {len(ai_black.wins):d} 次, {ai_white.color} 胜 {len(ai_white.wins):d} 次')
    
    
