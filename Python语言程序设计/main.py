from os.path import exists
from train import train, evaluate
from model import *
from time import sleep

epoch = 100
learning = 0.0003
loss = torch.nn.CrossEntropyLoss()
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model_name = "Convmixer"
model = ConvMixer(n_classes = 5, dim = 256, depth = 10).to(device)
if exists(model_name + ".pth"):
    model.load_state_dict(torch.load(model_name + ".pth"))
optimizer = torch.optim.Adam(model.parameters(), lr = learning)

if __name__ == "__main__":
    print("using {} device.".format(device))
    print("using {} model.".format(model_name))
    if exists(model_name + ".pth"):
        print("Having loaded weight " + model_name + ".pth!")
    valid_accur_all, file_name = [], "Acc_" + model_name + ".txt"
    if exists(file_name):
        with open(file_name, 'r') as file:
            valid_accur_all = [float(i) for i in file.read().strip().split('\n')]  # 存放测试集准确率的数组

    for i in range(epoch):  # 开始迭代
        print("--------------- Epoch：{} Start ---------------".format(i + 1))
        sleep(0.1)
        train_loss, train_accuracy = train(model, optimizer, loss, device)
        sleep(0.1)
        print("train-Loss：{:.5f} , train-accuracy：{:.5f}".format(train_loss, train_accuracy))  # 输出训练情况

        sleep(0.1)
        valid_loss, valid_accuracy = evaluate(model, loss, device, "valid")
        sleep(0.1)
        print("valid-Loss：{:.5f} , valid-accuracy：{:.5f}".format(valid_loss, valid_accuracy))
        valid_accur_all.append(round(valid_accuracy, 5))
        with open(file_name, 'a') as file:
            file.write("%.3f" % valid_accuracy + '\n')
        print("--------------- Epoch：{} End ---------------".format(i + 1))

        if valid_accur_all[-1] == max(valid_accur_all) \
                or (i + 1) % 12 == 0 and max(valid_accur_all) - valid_accur_all[-1] <= 0.03:
            torch.save(model.state_dict(), model_name + ".pth")
            print("Having saved weight as " + model_name + ".pth!")
