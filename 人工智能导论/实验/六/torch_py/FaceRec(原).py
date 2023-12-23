import torch
import numpy as np

from PIL import Image
from PIL import Image, ImageDraw, ImageFont
from matplotlib import pyplot as plt  # 展示图片
from torchvision.transforms import transforms

try:
    from MTCNN.detector import FaceDetector
    from MobileNetV1 import MobileNetV1
except:
    from .MTCNN.detector import FaceDetector
    from .MobileNetV1 import MobileNetV1


def plot_image(image, image_title="", is_axis=False):
    """
    展示图像
    :param image: 展示的图像，一般是 np.array 类型
    :param image_title: 展示图像的名称
    :param is_axis: 是否需要关闭坐标轴，默认展示坐标轴
    :return:
    """
    # 展示图片
    plt.imshow(image)

    # 关闭坐标轴,默认关闭
    if not is_axis:
        plt.axis('off')

    # 展示受损图片的名称
    plt.title(image_title)

    # 展示图片
    plt.show()


class Recognition(object):
    classes = ["mask", "no_mask"]

    # def __init__(self, mobilenet_path="./results/test.pth"):
    def __init__(self, model_path=None):
        """
        :param: mobilenet_path: XXXX.pth
        """
        self.detector = FaceDetector()
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.mobilenet = MobileNetV1(classes=2)
        if model_path:
            self.mobilenet.load_state_dict(
                torch.load(model_path, map_location=device))

    def face_recognize(self, image):
        # 绘制并保存标注图
        drawn_image = self.detector.draw_bboxes(image)
        return drawn_image

    def mask_recognize(self, image):
        b_boxes, _ = self.detector.detect(image)
        detect_face_img = self.detector.draw_bboxes(image)
        face_num = len(b_boxes)
        mask_num = 0
        for box in b_boxes:
            face = image.crop(tuple(box[:4]))
            face = np.array(face)
            face = transforms.ToTensor()(face).unsqueeze(0)
            self.mobilenet.eval()
            with torch.no_grad():
                predict_label = self.mobilenet(face).cpu().data.numpy()
            current_class = self.classes[np.argmax(predict_label).item()]
            draw = ImageDraw.Draw(detect_face_img)
            text_position = (box[0], box[1])  # 使用人脸框左上角坐标作为标签的位置
            if current_class == "mask":
                mask_num += 1
                draw.text(text_position, u'YES', 'fuchsia')
            else:
                draw.text(text_position, u'NO', 'fuchsia')

        return detect_face_img, face_num, mask_num


"""
检测人脸，返回人脸位置坐标
其中b_boxes是一个n*5的列表、landmarks是一个n*10的列表，n表示检测出来的人脸个数，数据详细情况如下：
bbox：[左上角x坐标, 左上角y坐标, 右下角x坐标, 右下角y坐标, 检测评分]
landmark：[右眼x, 左眼x, 鼻子x, 右嘴角x, 左嘴角x, 右眼y, 左眼y, 鼻子y, 右嘴角y, 左嘴角y]
"""
if __name__ == "__main__":
    torch.set_num_threads(1)
    detector = FaceDetector()
    img = Image.open("./test1.jpg")
    recognize = Recognition()

    """---detect face--"""
    # draw = recognize.face_recognize(img)
    # plot_image(draw)

    """---crop face ---"""
    draw, all_num, mask_nums = recognize.mask_recognize(img)
    plot_image(draw)
    print("all_num:", all_num, "mask_num", mask_nums)
