<?php
date_default_timezone_set("UTC");

// Capture IP address
$ip = $_SERVER['REMOTE_ADDR'];
$log = "Time: " . date("Y-m-d H:i:s") . " | IP: $ip\n";

// Write to correct IP log file
file_put_contents("../../logs/facebook_ip.txt", $log, FILE_APPEND);
?>
