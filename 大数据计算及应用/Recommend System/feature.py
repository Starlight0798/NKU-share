train_path = './data/train.txt'

def get_statistics(file_path):
    user_set = set()
    item_set = set()
    rating_count = 0

    max_user_id = 0
    max_item_id = 0
    average_rating = 0.0

    with open(file_path, 'r') as f:
        while (line := f.readline()) != '':
            user_id, num = map(int, line.strip().split('|'))
            user_set.add(user_id)
            max_user_id = max(max_user_id, user_id)
            rating_count += num
            for _ in range(num):
                line = f.readline()
                item_id, score = line.strip().split()
                item_id, score = int(item_id), float(score)
                average_rating += score
                item_set.add(item_id)
                max_item_id = max(max_item_id, item_id)
    average_rating /= rating_count

    print("Number of users:", len(user_set))
    print("Number of rated items:", len(item_set))
    print("Number of ratings:", rating_count)
    print("Max user ID:", max_user_id)
    print("Max item ID:", max_item_id)
    print("Average rating:", average_rating)

get_statistics(train_path)
