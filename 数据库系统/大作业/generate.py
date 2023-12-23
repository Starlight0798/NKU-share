import random
import numpy as np
from datetime import datetime, timedelta
from faker import Faker

fake = Faker('zh_CN')

stu_num = 300
course_names = [
    '计算机网络', '计算机组成原理',  # 计算机与信息工程学院的课程
    '数字电路', '模拟电路',  # 电子与通信工程学院的课程
    '机械制图', '工业生产导论',  # 机械工程学院的课程
    '新型材料挖掘', '高分子材料工程',  # 材料科学与工程学院的课程
    '经济学概论', '国际经济与贸易概论',  # 经济管理学院的课程
    '高等数学', '统计金融学',  # 数学与统计学院的课程
    '雅思英语', '日语专精',  # 外国语学院的课程
    '土木工程导论', '道路设计',  # 土木工程学院的课程
    '人类与环境', '环境工程导论',  # 环境科学与工程学院的课程
    '致命的生物', '生物医学导论',   # 生命科学与技术学院的课程
    '艺术史', '设计概论',  # 艺术与设计学院的课程
    '法律概论', '法律文书写作',  # 法学院的课程
    '马克思主义基本原理', '近代历史纲要',  # 马克思主义学院的课程
    '体育概论', '体育心理学',  # 体育学院的课程
    '国际贸易实务', '国际金融实务',  # 国际教育学院的课程
    '计算机应用基础', '计算机网络原理'  # 职业技术学院的课程
]
department_names = [
    '计算机与信息工程学院', '电子与通信工程学院', '机械工程学院', '材料科学与工程学院', 
    '经济管理学院', '数学与统计学院', '外国语学院', '土木工程学院', 
    '环境科学与工程学院', '生命科学与技术学院', '艺术与设计学院', '法学院',
    '马克思主义学院', '体育学院', '国际教育学院', '职业技术学院'
    ]
majors = [
    ['计算机科学与技术', '软件工程', '网络工程'],
    ['电子信息', '通信工程', '自动化'],
    ['机械工程', '工业设计', '车辆工程'],
    ['材料科学与工程', '高分子材料与工程', '无机材料'],
    ['经济学', '国际经济与贸易', '金融学'],
    ['数学与应用数学', '统计学', '信息与计算科学'],
    ['英语', '日语', '法语'],
    ['土木工程', '道路与桥梁', '水利与水电工程'],
    ['环境工程', '环境科学', '生态学'],
    ['生物技术', '生物信息学', '生物医学工程'],
    ['视觉传达设计', '环境设计', '产品设计'],
    ['法学', '知识产权', '法律'],
    ['思想政治教育', '马克思主义理论', '近代史纲教育'],
    ['体育教育', '社会体育指导与管理', '运动训练'],
    ['国际经济与贸易', '国际金融', '国际商务'],
    ['计算机应用技术', '软件技术', '网络技术']
]
departments = [i for i in range(1, 1 + len(department_names))]
courses = [i for i in range(100001, 100001 + len(course_names))]

file = open('./data.sql', 'w', encoding='utf-8')

# 生成部门数据
for i in range(len(department_names)):
    sql = f"INSERT INTO department (dname, dadd, dmng, dtel) VALUES ('{department_names[i]}', '{fake.address()}', '{fake.name()}', '{fake.phone_number()}')"
    file.write(sql + ';\n')

# 生成专业数据
for i in range(len(department_names)):
    for major_name in majors[i]:
        sql = f"INSERT INTO major (did, mname) VALUES ({departments[i]}, '{major_name}')"
        file.write(sql + ';\n')

# 生成学生数据
for i in range(stu_num):
    sid = 20211000 + i
    mid = random.randint(1, len(majors) * len(majors[0]))
    sql = f"INSERT INTO student (sid, name, sex, age, class, idnum, mid, email, tel) VALUES ({sid}, '{fake.name()}', '{random.choice(['男', '女'])}', '{random.randint(18, 25)}', '班级{i % 5 + 1}', '{fake.ssn()}', {mid}, '{fake.email()}', '{fake.phone_number()}')"
    file.write(sql + ';\n')
    
# 生成课程数据
course_id = 100001
for did in departments:
    for i in range(2):  # 为每个学院分配两门课程
        credit = np.random.choice([0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0], p=[0.05, 0.05, 0.1, 0.1, 0.15, 0.2, 0.15, 0.1, 0.05, 0.05])
        cname = course_names[(did - 1) * 2 + i]  # 从course_names列表中选择对应的课程名称
        sql = f"INSERT INTO course (cid, cname, credit, cadd, did, tname) VALUES ({course_id}, '{cname}', {credit}, '{fake.building_number()}教室', {did}, '{fake.name()}')"
        file.write(sql + ';\n')
        course_id += 1
    
        
# 生成学生课程数据, 每个学生随机选择3-6门课程
for i in range(stu_num):
    sid = 20211000 + i
    selected_courses = random.sample(courses, random.randint(3, 6))
    for cid in selected_courses:
        status = np.random.choice([0, 1], p=[0.9, 0.1])
        # 学生分数分为0-59, 60-69, 70-79, 80-89, 90-100五个等级, 且各等级的概率不同
        score = np.random.choice([random.randint(0, 59), random.randint(60, 69), random.randint(70, 79), random.randint(80, 89), random.randint(90, 100)], p=[0.1, 0.2, 0.3, 0.2, 0.2])
        sql = f"INSERT INTO student_course (sid, cid, score, status) VALUES ({sid}, {cid}, '{score}', '{status}')"
        file.write(sql + ';\n')


# 生成学生奖惩数据
log_types = ['奖励', '惩罚']
# 每个学生随机生成1-5条奖惩记录
for i in range(stu_num):
    sid = 20211000 + i
    for j in range(random.randint(1, 5)):
        logdate = datetime.now() - timedelta(days=random.randint(1, 365))
        addtime = logdate + timedelta(hours=random.randint(0, 23), minutes=random.randint(0, 59), seconds=random.randint(0, 59))
        log_type = random.choice(log_types)
        reason = f"{log_type}原因: {fake.sentence(nb_words=6)}"
        detail = f"{log_type}详情: {fake.paragraph(nb_sentences=2)}"
        sql = f"INSERT INTO student_log (sid, type, reason, detail, logdate, addtime) VALUES ({sid}, '{log_type}', '{reason}', '{detail}', '{logdate.strftime('%Y-%m-%d')}', '{addtime.strftime('%Y-%m-%d %H:%M:%S')}')"
        file.write(sql + ';\n')

# 生成管理员数据
admin_names = [fake.name() for _ in range(10)]
for i, admin_name in enumerate(admin_names):
    adminID = 95000 + i
    pwd = '123456'
    sql = f"INSERT INTO user_admin (adminID, adminName, pwd) VALUES ({adminID}, '{admin_name}', '{pwd}')"
    file.write(sql + ';\n')

file.close()
print("测试数据生成完成！")