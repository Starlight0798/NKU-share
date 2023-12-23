import torch
import matplotlib.pyplot as plt
from dataset import *
from tqdm import tqdm


def train(model, optimizer, loss, device):
    train_num, train_total_loss, train_total_accuracy = 0.0, 0.0, 0.0
    model.to(device)
    model.train()  # 将模型设置成 训练模式
    train_bar = tqdm(train_data_loader, desc = "train")  # 用于进度条显示，没啥实际用处
    for step, data in enumerate(train_bar):  # 开始迭代跑， enumerate这个函数不懂可以查查，将训练集分为 step是序号，data是数据
        img, target = data  # 将data 分位 img图片，target标签
        img, target = img.to(device), target.to(device)
        optimizer.zero_grad()  # 清空历史梯度
        outputs = model(img)  # 将图片打入网络进行训练,outputs是输出的结果
        loss_fn = loss(outputs, target)  # 计算神经网络输出的结果outputs与图片真实标签target的差别-这就是我们通常情况下称为的损失
        outputs = torch.argmax(outputs, 1)  # 最大的值就是我们预测的结果 求最大值
        train_total_loss += loss_fn.item() * img.size(0)  # 将所有损失的绝对值加起来
        train_total_accuracy += torch.eq(outputs, target).sum().item()  # 求训练集的准确率
        train_num += img.size(0)
        loss_fn.backward()  # 神经网络反向传播
        optimizer.step()  # 梯度优化 用上面的adam优化

    return train_total_loss / train_num, train_total_accuracy / train_num


def evaluate(model, loss, device, data_name):
    data_num, data_loss, data_accuracy = 0.0, 0.0, 0.0
    model.to(device)
    model.eval()
    loader = test_data_loader if data_name == "test" else val_data_loader
    data_bar = tqdm(loader, desc = data_name)
    with torch.no_grad():  # 清空历史梯度，进行测试  与训练最大的区别是测试过程中取消了反向传播
        for data in data_bar:
            img, target = data
            img, target = img.to(device), target.to(device)
            outputs = model(img)
            loss_fn = loss(outputs, target)
            outputs = torch.argmax(outputs, 1)
            data_loss += loss_fn.item() * img.size(0)
            data_accuracy += torch.eq(outputs, target).sum().item()
            data_num += img.size(0)

    return data_loss / data_num, data_accuracy / data_num


def visualize(epoch, train_loss_all, train_accur_all, data_loss_all, data_accur_all, data_type = "Valid"):
    plt.figure(figsize = (12, 4))
    plt.subplot(1, 2, 1)
    plt.plot(range(epoch), train_loss_all,
             "ro-", label = "Train loss")
    plt.plot(range(epoch), data_loss_all,
             "bs-", label = data_type + " loss")
    plt.legend()
    plt.xlabel("epoch")
    plt.ylabel("Loss")
    plt.subplot(1, 2, 2)
    plt.plot(range(epoch), train_accur_all,
             "ro-", label = "Train accur")
    plt.plot(range(epoch), data_accur_all,
             "bs-", label = data_type + " accur")
    plt.xlabel("epoch")
    plt.ylabel("acc")
    plt.legend()
    plt.show()
