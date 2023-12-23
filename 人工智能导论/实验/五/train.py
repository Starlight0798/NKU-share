import os
import pandas as pd
import joblib
# from sklearn.externals import joblib
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn.metrics import silhouette_score, calinski_harabasz_score
from sklearn.preprocessing import StandardScaler

file_dir = './data'

# 读取数据并合并
df_features = []
for col in ('cpc', 'cpm'):
    path = os.path.join(file_dir, col + '.csv')
    df_feature = pd.read_csv(path)
    df_features.append(df_feature)

df = pd.merge(left=df_features[0], right=df_features[1])
df['timestamp'] = pd.to_datetime(df['timestamp'])

# 特征工程
df['cpc X cpm'] = df['cpm'] * df['cpc']
df['cpc / cpm'] = df['cpc'] / df['cpm']
df['hours'] = df['timestamp'].dt.hour
df['daylight'] = ((df['hours'] >= 9) & (df['hours'] <= 18)).astype(int)

# 特征标准化
columns = ['cpc', 'cpm', 'cpc X cpm', 'cpc / cpm']
data = df[columns]
scaler = StandardScaler()
data = scaler.fit_transform(data)
data = pd.DataFrame(data, columns=columns)

# PCA降维
n_components = 3
pca = PCA(n_components=n_components)
data = pca.fit_transform(data)
data = pd.DataFrame(data, columns=['Dimension' + str(i + 1) for i in range(n_components)])

# KMeans聚类
kmeans = KMeans(n_clusters=2, init='k-means++', n_init=50, max_iter=500)
kmeans.fit(data)

# 计算轮廓系数
score = silhouette_score(data, kmeans.labels_)
print("Silhouette score:", score)

# 计算 Calinski-Harabasz
score = calinski_harabasz_score(data, kmeans.labels_)
print("Calinski-Harabasz score:", score)

# 保存模型
joblib.dump(kmeans, './results/model.pkl')
joblib.dump(scaler, './results/scaler.pkl')
joblib.dump(pca, './results/pca.pkl')

print('over.')
