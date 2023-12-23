from os.path import exists
from model import *
import torch
from train import evaluate

loss = torch.nn.CrossEntropyLoss()
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
'''model_name = "Resnet50"
model = resnet50(num_classes = 5).to(device)'''

model_name = "Convmixer"
model = ConvMixer(n_classes = 5, dim = 256, depth = 10).to(device)

if exists(model_name + ".pth"):
    model.load_state_dict(torch.load(model_name + ".pth"))

def test_predict(model, loss, device, model_name):
    print("--------------- Test Start ---------------")
    if exists(model_name + ".pth"):
        print("The test is using saved weight from model " + model_name + "!")
    test_loss, test_accuracy = evaluate(model, loss, device, "test")
    print("test-Loss：{:.5f} , test-accuracy：{:.5f}".format(test_loss, test_accuracy))
    print("--------------- Test End ---------------")

if __name__ == "__main__":
    test_predict(model, loss, device, model_name)
