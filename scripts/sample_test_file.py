import requests


url = "https://hub.docker.com//v2/users/login"
data = {
    "username": "phull.kanav@gmail.com", 
    "password": "rapidfort_1234"
}
response = requests.post(url, json=data)
if response.status_code == 200:
    print(response.json()["token"])
else:
    raise Exception("Failed to authenticate with Docker Hub API")