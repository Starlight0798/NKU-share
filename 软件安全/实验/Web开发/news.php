<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<title>主页</title>
</head> 
<body>
<div align="center">
 <table width="900" border="0" cellspacing="0" cellpadding="0">
 <tr>
 <td height="40"><form id="form1" name="form1" method="post" action="loginok.php">
 <div align="right">用户名：
 <input name="username" type="text" id="username" size="12" />
 密码：
 <input name="password" type="password" id="password" size="12" />
 <input type="submit" name="Submit" value="提交" />
 </div>
 </form>
 </td>
 </tr>
 <tr>
 <td><hr /></td>
 </tr>
 <tr>
 <td height="300" align="center" valign="top"><p>&nbsp;</p>
<?php
 $conn=mysql_connect("localhost", "root", "123456"); 
 $newsid = $_GET['newsid'];
 $SQLStr = "select * from news where newsid=$newsid";
 $result=mysql_db_query("testDB", $SQLStr, $conn); 
 if ($row=mysql_fetch_array($result))//通过循环读取数据内容 
 { 
 // 定位到第一条记录
 mysql_data_seek($result, 0);
 // 循环取出记录
 while ($row=mysql_fetch_row($result))
 { 
 echo "$row[1]<br>";
 echo "$row[2]<br>";
 }
 }
 // 释放资源
 mysql_free_result($result);
 // 关闭连接
 mysql_close($conn); 
 
?>
</td>
 </tr>
 </table>
</div>
</body>
</html>