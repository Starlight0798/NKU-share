import warnings
warnings.filterwarnings('ignore')
from torch_py.FaceRec import Recognition, plot_image
from PIL import Image
import numpy as np
import cv2

model_path = 'results/temp.pth'

def predict(img):
    if isinstance(img, np.ndarray):
        img = Image.fromarray(cv2.cvtColor(img,cv2.COLOR_BGR2RGB))
    recognize = Recognition(model_path)
    img, all_num, mask_num = recognize.mask_recognize(img)
    return img, all_num, mask_num

img = cv2.imread("./test.jpg")
img, all_num, mask_nums = predict(img)
plot_image(img)
print("图中的人数有：" + str(all_num) + "个")
print("戴口罩的人数有：" + str(mask_nums) + "个")