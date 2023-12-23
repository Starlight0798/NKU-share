import warnings
warnings.filterwarnings('ignore')
import joblib

pipeline_path = './results/pipeline.model'
pipeline = joblib.load(pipeline_path)


def predict(message):
    """
    预测短信短信的类别和每个类别的概率
    param: message: 经过jieba分词的短信，如"医生 拿 着 我 的 报告单 说 ： 幸亏 你 来 的 早 啊"
    return: label: 整数类型，短信的类别，0 代表正常，1 代表恶意
            proba: 列表类型，短信属于每个类别的概率，如[0.3, 0.7]，认为短信属于 0 的概率为 0.3，属于 1 的概率为 0.7
    """
    label = pipeline.predict([message])[0]
    proba = list(pipeline.predict_proba([message])[0])

    return label, proba


if __name__ == '__main__':
    import pandas as pd
    import numpy as np
    data_eval = pd.read_csv("./datasets/5f9ae242cae5285cd734b91e-momodel/sms_pub.csv", encoding='utf8')
    y_eval = np.array(data_eval['label'][:5000])
    X_eval = np.array(data_eval['msg_new'][:5000])
    total = y_eval.shape[0]
    count_y, count_w = 0, 0
    for x, y in zip(X_eval, y_eval):
        y_pred, _ = predict(x)
        if y_pred == y:
            count_y += 1
        else:
            count_w += 1
        acc = count_y / (count_y + count_w)
        print(f'正确: {count_y}  错误: {count_w}  当前正确率: {acc:.3f}')
