<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<title>主页</title>
</head>
<?php
$conn=mysql_connect("localhost", "root", "123456"); 
?>
<body>
<div align="center">
 <table width="900" border="0" cellspacing="0" cellpadding="0">
 <tr>
 <td height="40"><form id="form1" name="form1" method="post" action="add.php">
 <div align="right">新闻标题：
 <input name="topic" type="text" id="topic" size="50" />
 <BR>
 新闻内容：
 <textarea name="content" cols="60" rows="8" id="content"></textarea><BR>
 <input type="submit" name="Submit" value="添加" />
 </div>
 </form>
 </td>
 </tr>
 <tr>
 <td><hr /></td>
 </tr>
 <tr>
 <td height="300" align="center" valign="top"><table width="600" border="0" cellspacing="0" 
cellpadding="0">
 <tr>
 <td width="100" height="30"><div align="center">新闻序号</div></td>
 <td><div align="center">新闻标题</div></td>
 <td><div align="center">删除</div></td>
 </tr>
<?php 
 $SQLStr = "select * from news";
 $result=mysql_db_query("testDB", $SQLStr, $conn); 
 if ($row=mysql_fetch_array($result))//通过循环读取数据内容 
 { 
 // 定位到第一条记录
 mysql_data_seek($result, 0);
 // 循环取出记录
 while ($row=mysql_fetch_row($result))
 { 
?> 
<tr>
 <td height="30"><div align="center"> <?php echo $row[0] ?> </div></td>
 <td width="400"> <div align="center"> <?php echo $row[1] ?> </div></td>
 <td><div align="center"><a href="del.php?newsid=<?php echo $row[0] ?> " > 删 除 </a> 
</div></td>
 </tr>
<?php 
 }
 }
?>
 </table></td>
 </tr>
 </table>
</div>
</body>
</html>
<?php 
 // 释放资源
 mysql_free_result($result);
 // 关闭连接
 mysql_close($conn); 
?>