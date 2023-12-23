import warnings
import copy
from tqdm.auto import tqdm
import torch
import torch.nn as nn
import torch.optim as optim
from torchvision.datasets import ImageFolder
import torchvision.transforms as T
from torch.utils.data import DataLoader
from torchvision import models

# 忽略警告
warnings.filterwarnings('ignore')

# 设置线程数量
torch.set_num_threads(6)

# 数据处理部分
def processing_data(data_path, height=224, width=224, batch_size=32, test_split=0.1):
    transforms = T.Compose([
        T.Resize((height, width)),
        T.RandomHorizontalFlip(0.1),
        T.RandomVerticalFlip(0.1),
        T.RandomRotation(15),
        T.RandomResizedCrop(height, scale=(0.8, 1.0)),
        T.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2, hue=0.1),
        T.RandomAffine(degrees=15, translate=(0.1, 0.1), scale=(0.9, 1.1), shear=10),
        T.RandomPerspective(distortion_scale=0.3, p=0.5),
        T.ToTensor(),
        T.Normalize([0], [1]),
    ])


    dataset = ImageFolder(data_path, transform=transforms)
    train_size = int((1 - test_split) * len(dataset))
    test_size = len(dataset) - train_size
    train_dataset, test_dataset = torch.utils.data.random_split(dataset, [train_size, test_size])
    train_data_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    valid_data_loader = DataLoader(test_dataset, batch_size=1000, shuffle=True)

    return train_data_loader, valid_data_loader

# 载入数据
data_path = './datasets/5f680a696ec9b83bb0037081-momodel/data/image'
train_data_loader, valid_data_loader = processing_data(data_path=data_path, height=160, width=160, batch_size=32, test_split=0.2)

device = torch.device("cuda:0") if torch.cuda.is_available() else torch.device("cpu")

# 定义模型、优化器和损失函数
model = models.resnet50(pretrained=True)
num_ftrs = model.fc.in_features
model.fc = nn.Linear(num_ftrs, 2)


model = model.to(device)
optimizer = optim.Adam(model.parameters(), lr=1e-3)
scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, 'max', factor=0.5, patience=2)
criterion = nn.CrossEntropyLoss()

# 训练和验证
epochs = 10
best_acc = 0
best_model_weights = copy.deepcopy(model.state_dict())

for epoch in range(epochs):
    model.train()
    running_loss = 0.0

    for x, y in tqdm(train_data_loader):
        x = x.to(device)
        y = y.to(device)
        pred_y = model(x)
        loss = criterion(pred_y, y)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        running_loss += loss.item()

    train_loss = running_loss / len(train_data_loader)

    model.eval()
    total = 0
    right_cnt = 0
    valid_loss = 0.0

    with torch.no_grad():
        for b_x, b_y in valid_data_loader:
            b_x = b_x.to(device)
            b_y = b_y.to(device)
            output = model(b_x)
            loss = criterion(output, b_y)
            valid_loss += loss.item()
            pred_y = torch.max(output, 1)[1]
            right_cnt += (pred_y == b_y).sum()
            total += b_y.size(0)

    valid_loss = valid_loss / len(valid_data_loader)
    accuracy = right_cnt.float() / total    
    print(f'Epoch: {epoch+1}/{epochs} || Train Loss: {train_loss:.4f} || Val Loss: {valid_loss:.4f} || Val Acc: {accuracy:.4f}')
    # 更新学习率
    scheduler.step(valid_loss)
    # 保存最佳模型权重
    if accuracy > best_acc:
        best_model_weights = copy.deepcopy(model.state_dict())
        best_acc = accuracy
        torch.save(best_model_weights, './results/temp.pth')

print(f'Best Accuracy: {best_acc:.4f}')
print('Finish Training.')
