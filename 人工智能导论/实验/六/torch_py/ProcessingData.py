from torchvision.datasets import ImageFolder
import torchvision.transforms as T
from torch.utils.data import Dataset
from torch.utils.data import DataLoader
# from Utils import plot_image
import torch
import numpy as np


def show_tensor_img(img_tensor):
    img = img_tensor[0].data.numpy()
    img = np.swapaxes(img, 0, 2)
    img = np.swapaxes(img, 0, 1)
    img = np.array(img)
    plot_image(img)


def processing_data(data_path, height=224, width=224,
                    batch_size=32,
                    test_split=0.1):
    transforms = T.Compose([
        T.Resize((height, width)),
        T.RandomHorizontalFlip(0.1),  # 进行随机水平翻转
        T.RandomVerticalFlip(0.1),  # 进行随机竖直翻转
        T.ToTensor(),  # 转化为张量
        T.Normalize([0], [1]),  # 归一化
    ])

    dataset = ImageFolder(data_path, transform=transforms)
    n = len(dataset)
    n_valid = int(test_split * n)  # take ~10% for validate
    valid_set = torch.utils.data.Subset(dataset, range(n_valid))  # take first 10%
    train_set = torch.utils.data.Subset(dataset, range(n_valid, n))  # take the rest

    train_data_loader = DataLoader(train_set, batch_size=batch_size, shuffle=True)
    valid_data_loader = DataLoader(valid_set, batch_size=batch_size, shuffle=True)
    
    return train_data_loader, valid_data_loader


if __name__ == "__main__":
    data_path = './datasets/5f680a696ec9b83bb0037081-momodel/data/image'
    train_data_loader, valid_data_loader = processing_data(
        data_path=data_path, 
        height=160, width=160, 
        batch_size=32
    )

    for index, (x, labels) in enumerate(train_data_loader):
        print(index, x[0], labels)
        show_tensor_img(x)
        break
