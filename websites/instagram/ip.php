<?php
$ip = $_SERVER['REMOTE_ADDR'];
$ua = $_SERVER['HTTP_USER_AGENT'];
$log = "IP: $ip | Agent: $ua\n";
file_put_contents("../../logs/ip.txt", $log, FILE_APPEND);
?>
<img src="#" width="1" height="1">
