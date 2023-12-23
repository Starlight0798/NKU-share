import warnings
warnings.filterwarnings('ignore')
import os
os.environ["HDF5_USE_FILE_LOCKING"] = "FALSE"
import pandas as pd
import numpy as np
import joblib
from sklearn import metrics
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import MaxAbsScaler
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression


def read_stopwords(stopwords_path):
    with open(stopwords_path, 'r', encoding='utf-8') as f:
        stopwords = f.read()
    stopwords = stopwords.splitlines()
    return stopwords

# 数据集的路径
data_path = "./datasets/5f9ae242cae5285cd734b91e-momodel/sms_pub.csv"
# 读取数据
sms = pd.read_csv(data_path, encoding='utf-8')
# 停用词库路径
stopwords_path = './datasets/5f9ae242cae5285cd734b91e-momodel/scu_stopwords.txt'
# 读取停用词
stopwords = read_stopwords(stopwords_path)
# 导入数据
X = np.array(sms.msg_new)
y = np.array(sms.label)
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=45, test_size=0.1)

print("总共的数据大小", X.shape)
print("训练集数据大小", X_train.shape)
print("测试集数据大小", X_test.shape)


pipeline_list = [
    #('tfidf', TfidfVectorizer(token_pattern=r"(?u)\b\w+\b", stop_words=stopwords)),
    #('MaxAbsScaler', MaxAbsScaler()),
    #('clf', MultinomialNB())

    ('tfidf', TfidfVectorizer(ngram_range=(1,3),token_pattern=r"(?u)\b\w+\b",stop_words=stopwords)),
    ('clf', MultinomialNB(alpha=0.99))

    #('tfidf', TfidfVectorizer(ngram_range=(1, 3), token_pattern=r"(?u)\b\w+\b", stop_words=stopwords)),
    #('clf', SVC(kernel='linear', C=1))

    #('tfidf', TfidfVectorizer(ngram_range=(1, 2), token_pattern=r"(?u)\b\w+\b", stop_words=stopwords, max_df=0.95, min_df=2)),
    #('MaxAbsScaler', MaxAbsScaler()),
    #('clf', LogisticRegression(C=1, penalty='l2', solver='liblinear'))
]


# 搭建 pipeline
pipeline = Pipeline(pipeline_list)

# 训练 pipeline
print("第一次训练开始!")
pipeline.fit(X_train, y_train)
print("第一次训练结束!")
# 对测试集的数据集进行预测
y_pred = pipeline.predict(X_test)

# 在测试集上进行评估
print("在测试集上的混淆矩阵：")
print(metrics.confusion_matrix(y_test, y_pred))
print("在测试集上的分类结果报告：")
print(metrics.classification_report(y_test, y_pred))
print("在测试集上的 f1-score ：")
print(metrics.f1_score(y_test, y_pred))
print('在测试集上的准确率：')
print(metrics.accuracy_score(y_test, y_pred))

# 在所有的样本上训练一次，充分利用已有的数据，提高模型的泛化能力
print("第二次训练开始!")
pipeline.fit(X, y)
print("第二次训练结束!")
# 保存训练的模型，请将模型保存在 results 目录下

pipeline_path = './results/pipeline.model'
print("正在保存权重......")
joblib.dump(pipeline, pipeline_path)
print("成功保存权重!")