from flask import Flask,render_template
import socket

app = Flask(__name__)

@app.route("/")
def index():
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        return render_template('index.html', hostname=host_name, ip=host_ip, message = "Home page")
    except:
        return render_template('error.html')

@app.route("/app1")
def app1():
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        return render_template('index.html', hostname=host_name, ip=host_ip, message = "App1 page")
    except:
        return render_template('error.html')

@app.route("/app2")
def app2():
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        return render_template('index.html', hostname=host_name, ip=host_ip, message = "App2 page")
    except:
        return render_template('error.html')

@app.route("/admin")
def admin():
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        return render_template('index.html', hostname=host_name, ip=host_ip, message = "Admin page (privileged)")
    except:
        return render_template('error.html')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
