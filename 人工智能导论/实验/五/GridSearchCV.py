import os
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score
from sklearn.model_selection import GridSearchCV
from sklearn.base import BaseEstimator, ClusterMixin

# 自定义 KMeans 类，使其兼容 GridSearchCV
class CustomKMeans(BaseEstimator, ClusterMixin):
    def __init__(self, n_clusters=2, init='k-means++', n_init=10, max_iter=500, tol=1e-8):
        self.n_clusters = n_clusters
        self.init = init
        self.n_init = n_init
        self.max_iter = max_iter
        self.tol = tol

    def fit(self, X, y=None):
        self.kmeans_ = KMeans(n_clusters=self.n_clusters, init=self.init, n_init=self.n_init, max_iter=self.max_iter, tol=self.tol)
        self.kmeans_.fit(X)
        return self

    def predict(self, X):
        return self.kmeans_.predict(X)

# 自定义评分函数
def combined_scorer(estimator, X):
    labels = estimator.predict(X)
    silhouette = silhouette_score(X, labels)
    return silhouette

# 加载数据
file_dir = './data'
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
df['daylight'] = ((df['hours'] >= 7) & (df['hours'] <= 22)).astype(int)

# 特征标准化
columns = ['cpc', 'cpm', 'cpc X cpm', 'cpc / cpm']
data = df[columns]
scaler = StandardScaler()
data_scaled = scaler.fit_transform(data)

# PCA 降维
n_components = 3
pca = PCA(n_components=n_components)
data_pca = pca.fit_transform(data_scaled)

# 设置参数网格
param_grid = {
    'n_clusters': range(2, 8),
    'init': ['k-means++'],
    'n_init': range(50, 300, 50),
    'max_iter': [300, 500, 700]
}

# 创建自定义 KMeans 模型
model = CustomKMeans()

# 使用 GridSearchCV 进行参数优化
grid_search = GridSearchCV(model, param_grid, scoring=combined_scorer, cv=5, n_jobs=-1, verbose=1)
grid_search.fit(data_pca)

# 输出最佳参数
print("Best parameters found: ", grid_search.best_params_)
print("Best combined score: ", grid_search.best_score_)

# 将 cv_results_ 转换为 pandas DataFrame
results_df = pd.DataFrame(grid_search.cv_results_)

# 按照评分降序排列
results_df = results_df.sort_values(by='mean_test_score', ascending=False)

# 显示结果
print("所有尝试过的参数组合及其评分：")
print(results_df[['params', 'mean_test_score']])

