""" Helper script to delete rfstub tags """
import logging
import os
import time
import docker
import requests

class RegistryHelper:
    """ Docker registry helper base class"""

    def __init__(self, docker_client, username, password):
        self.username = username
        self.password = password
        self.docker_client = docker_client



class DockerHubHelper(RegistryHelper):
    """ Implement dockerhub helper """
    BASE_URL = "https://registry.hub.docker.com"

    def __init__(self, docker_client):
        username = os.environ.get("DOCKERHUB_USERNAME")
        password = os.environ.get("DOCKERHUB_PASSWORD")
        super(__class__, self).__init__(
            docker_client, username, password)

    @staticmethod
    def registry_url():
        """ registry url """
        return "docker.io"

    def get_rfstub_tag(self, account, repo):
        """
        Find rfstub tags using search_str"
        """
        tags = self._fetch_tags(account, repo)
        tags = list(filter(
            lambda tag: "rfstub" in tag["name"],
            tags))

        return map(lambda x:x.get("name"), tags)


    def _fetch_tags(self, account, repo):
        """
        Get tags from the dockerhub registry API
        """
        tags = []

        url = f"{self.BASE_URL}/v2/repositories/{account}/{repo}/tags?page_size=25"

        if account == "_":
            # Handle official repository here
            url = f"{self.BASE_URL}/v2/repositories/{repo}/tags?page_size=25"

        while url:
            resp = requests.get(url, timeout=60)
            logging.debug(f"url : {url}, {resp.status_code}, {resp.text}")
            if 200 <= resp.status_code < 300:
                tag_objs = resp.json()
                tags += tag_objs.get("results", [])
                url = tag_objs.get("next")
            else:
                break

        return tags

    def get_auth_header(self):
        """ get auth header for JWT """
        login_url = f"{self.BASE_URL}/v2/users/login"
        resp = requests.post(
            login_url,
            json={
                "username": self.username,
                "password": self.password
            },
            timeout=30
        )
        if resp.status_code == 200:
            resp_json = resp.json()
            logging.debug(resp_json)
            token = resp_json["token"]
            return {"Authorization": f"JWT {token}"}
        return {}

    def delete_tag(self, account, repo, tag):
        """ delete tags """
        del_url = f"{self.BASE_URL}/v2/repositories/{account}/{repo}/tags/{tag}/"
        auth_header = self.get_auth_header()
        resp = requests.delete(del_url, headers=auth_header, timeout=30)
        print(resp.status_code, resp.text, del_url)
        time.sleep(0.1)
        return resp.status_code == 200

if __name__ == "__main__":
    dc = docker.from_env()
    dh = DockerHubHelper(dc)
    repos_to_del = ['airflow',
                'airflow-scheduler',
                'airflow-worker',
                'apache',
                'apache-official',
                'consul',
                'curl',
                'envoy',
                'etcd',
                'fluentd',
                'haproxy',
                'influxdb',
                'kong',
                'mariadb',
                'mariadb-ib',
                'memcached',
                'mongodb',
                'mysql',
                'mysql8-ib',
                'mysql-official',
                'nats',
                'nginx',
                'nginx-ib',
                'nginx-official',
                'oncall',
                'postgresql',
                'postgresql12-ib',
                'prometheus',
                'rabbitmq',
                'redis-cluster',
                'redis6-ib',
                'redis-official',
                'zookeeper']
    for repo_to_del in repos_to_del:
        del_tags = dh.get_rfstub_tag("rapidfort", repo_to_del)
        for del_tag in del_tags:
            dh.delete_tag("rapidfort", repo_to_del, del_tag)
