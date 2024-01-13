import os
import yara
import datetime

# 定义YARA规则文件路径
rule_file = './rule_ex12.yar'

# 定义要扫描的文件夹路径
folder_path = './sample/'

# 加载YARA规则
try:
    rules = yara.compile(rule_file)
except yara.SyntaxError as e:
    print(f"YARA规则语法错误: {e}")
    exit(1)

# 获取当前时间
start_time = datetime.datetime.now()

# 扫描文件夹内的所有文件
scan_results = []

for root, dirs, files in os.walk(folder_path):
    for file in files:
        file_path = os.path.join(root, file)
        try:
            matches = rules.match(file_path)
            if matches:
                scan_results.append({'file_path': file_path, 'matches': [str(match) for match in matches]})
        except Exception as e:
            print(f"扫描文件时出现错误: {file_path} - {str(e)}")
   
# 计算扫描时间         
end_time = datetime.datetime.now()
scan_time = (end_time - start_time).seconds

# 将扫描结果写入文件
output_file = './scan_results.txt'

with open(output_file, 'w') as f:
    f.write(f"扫描开始时间: {start_time.strftime('%Y-%m-%d %H:%M:%S')}\n")
    f.write(f'扫描耗时: {scan_time}s\n')
    f.write("扫描结果:\n")
    for result in scan_results:
        f.write(f"文件路径: {result['file_path']}\n")
        f.write(f"匹配规则: {', '.join(result['matches'])}\n")
        f.write('\n')

print(f"扫描完成，耗时{scan_time}秒，结果已保存到 {output_file}")
