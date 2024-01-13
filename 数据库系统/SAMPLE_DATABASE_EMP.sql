
CREATE DATABASE IF NOT EXISTS emp
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;
use emp;
create table department
(
	deptno char(10) primary key,
	deptname char(10),
	location char(10)
);
insert into department values ('d1','开发部','天津');
insert into department values ('d2','财务部','北京');
insert into department values('d3','市场部','广东');

create table project(
	projectno char(10) primary key,
    projectname char(20),
    budget int
);
insert into project values ('p1','网络布线',120000);
insert into project values ('p2','软件升级',95000);
insert into project values ('p3','系统开发',185600);

create table employee
(
	empno int primary key,
    empname char(10),
    deptno char(10),
    foreign key (deptno) references department (deptno)
);
insert into employee values ('2581','徐唱','d2');
insert into employee values ('9031','李静','d2');
insert into employee values ('10102','王闻刚','d3');
insert into employee values ('18316','冯新','d1');
insert into employee values ('25348','张风','d3');
insert into employee values ('28559','刘国风','d1');
insert into employee values ('29346','赵东生','d2');

create table workson(
	empno int,
    projectno char(10),
    job char(20),
    enterdate date,
    foreign key (empno) references employee(empno),
    foreign key (projectno) references project(projectno),
    primary key (empno,projectno)
);
insert into workson values ('2581','p3','分析员','98-10-15');
insert into workson values ('9031','p1','管理员','98-4-15');
insert into workson values ('9031','p3','职员','97-11-15');
insert into workson values ('10102','p1','分析员','97-1-10');
insert into workson values ('10102','p3','管理员','99-1-1');
insert into workson values ('18316','p2','职员','98-2-15');
insert into workson values ('25348','p2',NULL,'98-6-1');
insert into workson values ('28559','p1',NULL,'98-8-1');
insert into workson values ('28559','p2','职员','99-2-1');
insert into workson values ('29346','p1','职员','98-1-4');
insert into workson values ('29346','p2',NULL,'97-12-15');