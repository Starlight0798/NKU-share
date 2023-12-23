import os
from torchvision import transforms
from torchvision.datasets import ImageFolder
from torch.utils.data import DataLoader
from os.path import join

data_dir = r".\datasets"

data_transform = {
    'train':
        transforms.Compose([
            transforms.Resize([224, 224]),
            transforms.RandomHorizontalFlip(p = 0.5),
            transforms.RandomVerticalFlip(p = 0.5),
            transforms.RandomRotation(90),
            transforms.ToTensor(),
            transforms.Normalize(mean = [0.485, 0.456, 0.406], std = [0.229, 0.224, 0.225])
        ]),
    'test':
        transforms.Compose([
            transforms.Resize([224, 224]),
            transforms.ToTensor(),
            transforms.Normalize(mean = [0.485, 0.456, 0.406], std = [0.229, 0.224, 0.225])
        ]),
    'valid':
        transforms.Compose([
            transforms.Resize([224, 224]),
            transforms.ToTensor(),
            transforms.Normalize(mean = [0.485, 0.456, 0.406], std = [0.229, 0.224, 0.225])
        ])
}

batch_size = 32
train_data = ImageFolder(root = join(data_dir, "train"), transform = data_transform['train'])
test_data = ImageFolder(root = join(data_dir, "test"), transform = data_transform['test'])
val_data = ImageFolder(root = join(data_dir, "valid"), transform = data_transform['valid'])

num_workers = min([os.cpu_count(), batch_size]) if batch_size > 1 else 0
train_data_loader = DataLoader(train_data, batch_size = batch_size, shuffle = True, num_workers = num_workers)
test_data_loader = DataLoader(test_data, batch_size = batch_size, shuffle = True, num_workers = num_workers)
val_data_loader = DataLoader(val_data, batch_size = batch_size, shuffle = True, num_workers = num_workers)
