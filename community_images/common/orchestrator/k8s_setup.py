""" K8s setup module """

import logging
import os
import subprocess
import backoff


class K8sSetup:
    """ k8s setup context manager """
    def __init__(
            self,
            namespace_name,
            release_name,
            image_tag_details,
            runtime_props,
            image_script_dir,
            command):
        self.namespace_name = namespace_name
        self.release_name = release_name
        self.image_tag_details = image_tag_details
        self.runtime_props = runtime_props or {}
        self.image_script_dir = image_script_dir
        self.command = command
        self.script_dir = os.path.abspath(os.path.dirname( __file__ ))

    def __enter__(self):
        """ create a k8s namespace and set it up for runner """

        # create namespace
        cmd=f"kubectl create namespace {self.namespace_name}"
        subprocess.check_output(cmd.split())

        # add rapidfortbot credentials
        docker_config_json_path = f"{os.environ.get('HOME')}/.docker/config.json"
        cmd=f"kubectl --namespace {self.namespace_name}"
        cmd +=" create secret generic rf-regcred"
        cmd +=f" --from-file=.dockerconfigjson={docker_config_json_path}"
        cmd +=" --type=kubernetes.io/dockerconfigjson"
        subprocess.check_output(cmd.split())

        # add tls certs
        cert_mgr_path = os.path.abspath(f"{self.script_dir}/../cert_managet_ns.yml")
        cmd=f"kubectl apply -f {cert_mgr_path} --namespace {self.namespace_name}"
        subprocess.check_output(cmd.split())

        # upgrade helm
        cmd="helm repo update"
        subprocess.check_output(cmd.split())

        # Install helm
        self.create_helm_chart(self.prepare_helm_cmd())

        # waiting for pod to be ready
        logging.info("waiting for pod to be ready")
        cmd=f"kubectl wait deployments {self.release_name}"
        cmd+=f" -n {self.namespace_name}"
        cmd+=" --for=condition=Available=True --timeout=10m"
        subprocess.check_output(cmd.split())

        return {
            "namespace_name": self.namespace_name,
            "release_name": self.release_name,
            "image_tag_details": self.image_tag_details
        }

    def prepare_helm_cmd(self):
        """ Prepare helm chart command """
        # Install helm
        override_file=f"{self.image_script_dir}/{self.runtime_props.get('override_file', 'overrides.yml')}"

        cmd=f"helm install {self.release_name}"
        cmd+=f" {self.runtime_props.get('helm_repo')}"
        cmd+=f" --namespace {self.namespace_name}"

        image_keys = self.runtime_props.get("image_keys", {})
        for repo_key, tag_details in self.image_tag_details.items():
            if repo_key in image_keys:
                repository_key = image_keys[repo_key]["repository"]
                tag_key = image_keys[repo_key]["tag"]

                repository_value = tag_details["repo_path"]
                tag_value = tag_details["tag"]

                cmd+=f" --set {repository_key}={repository_value}"
                cmd+=f" --set {tag_key}={tag_value}"

        cmd+=f" -f {override_file}"
        return cmd

    # pylint:disable=no-self-use
    @backoff.on_exception(backoff.expo, BaseException, max_time=300)
    def create_helm_chart(self, cmd):
        """ Create helm chart """
        logging.info(f"cmd: {cmd}")
        subprocess.check_output(cmd.split())

    def __exit__(self, type, value, traceback):
        """ clean up k8s namespace """
        # log pods
        cmd=f"kubectl -n {self.namespace_name} get pods"
        subprocess.check_output(cmd.split())

        cmd=f"kubectl -n {self.namespace_name} get svc"
        subprocess.check_output(cmd.split())

        # bring down helm install
        cmd=f"helm delete {self.release_name} --namespace {self.namespace_name}"
        subprocess.check_output(cmd.split())

        # delete the PVC associated
        cmd="kubectl -n {self.namespace_name} delete pvc --all"
        subprocess.check_output(cmd.split())

        # delete namespace
        cmd=f"kubectl delete namespace {self.namespace_name}"
        subprocess.check_output(cmd.split())
