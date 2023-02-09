""" Sample flask app for testing """
import socket
from flask import Flask,render_template # pylint: disable=import-error

app = Flask(__name__)

@app.route("/")
def index():
    """ add index route """
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        return render_template('index.html', hostname=host_name, ip=host_ip, message = "Home page")
    except Exception as _: # pylint: disable=broad-except
        return render_template('error.html')

@app.route("/app1")
def app1():
    """ app1 route """
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        return render_template('index.html', hostname=host_name, ip=host_ip, message = "App1 page")
    except Exception as _: # pylint: disable=broad-except
        return render_template('error.html')

@app.route("/app2")
def app2():
    """ app2 route """
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        return render_template('index.html', hostname=host_name, ip=host_ip, message = "App2 page")
    except Exception as _: # pylint: disable=broad-except
        return render_template('error.html')

@app.route("/admin")
def admin():
    """ admin route """
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        return render_template('index.html', hostname=host_name, ip=host_ip, message = "Admin page (privileged)")
    except Exception as _: # pylint: disable=broad-except
        return render_template('error.html')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
