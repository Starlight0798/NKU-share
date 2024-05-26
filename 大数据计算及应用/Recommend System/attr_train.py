from svd import SVD


if __name__ == '__main__':
    attr1 = SVD(model_path='./model_attr1', data_path='./data/train_attr1.pkl')
    attr2 = SVD(model_path='./model_attr2', data_path='./data/train_attr2.pkl')
    attr1.train(save=True, epochs=40)
    attr2.train(save=True, epochs=40)