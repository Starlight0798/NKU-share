<?php 
 $conn=mysql_connect("localhost", "root", "123456"); 
 mysql_select_db("testDB"); 
 $newsid = $_GET['newsid']; 
 $SQLStr = "delete from news where newsid=$newsid"; 
 echo $SQLStr;
 $result=mysql_query($SQLStr); 
 // ¹Ø±ÕÁ¬½Ó
 mysql_close($conn); 
 if ($result)
 {
 ?>
 <script> 
 alert("delete succes");
 window.location.href="sys.php"; 
 </script>
 <?php
 }
 else{
 ?>
 <script> 
 alert("delete failed");
 history.back(); 
 </script>
 <?php
 } 
?>