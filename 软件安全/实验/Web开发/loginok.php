<?php
 $loginok=0;
 $conn=mysql_connect("localhost", "root", "123456"); 
 $username = $_POST['username'];
 $pwd = $_POST['password'];
 $SQLStr = "SELECT * FROM userinfo where username='$username' and pwd='$pwd'"; 
 echo $SQLStr;
$result=mysql_db_query("testDB", $SQLStr, $conn); 
 if ($row=mysql_fetch_array($result))//通过循环读取数据内容 
 {
 $loginok=1;
 }
 // 释放资源
 mysql_free_result($result);
 // 关闭连接
 mysql_close($conn); 
 if ($loginok==1)
 {
 ?>
 <script> 
 alert("login succes");
 window.location.href="sys.php"; 
 </script>
 <?php
 }
 else{
 ?>
 <script> 
 alert("login failed");
 history.back(); 
 </script>
 <?php
 }
 
?>