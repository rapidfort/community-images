""" K8s setup module """

import logging
import os
import subprocess
import backoff
from commands import Commands
from utils import Utils


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
        self.preserve_namespace = False
        self.script_dir = os.path.abspath(os.path.dirname(__file__))

        try:
            cmd = f"kubectl get namespace {self.namespace_name}"
            Utils.run_cmd(cmd.split())
            logging.info(f"Namespace '{namespace_name}' exists.")
            self.preserve_namespace = True
        except subprocess.CalledProcessError as e:
            if b"NotFound" in e.output:
                logging.info(f"Namespace '{namespace_name}' does not exist.")
                self.preserve_namespace = False
            else:
                logging.info(f"Error checking namespace: {e}")
                self.preserve_namespace = False

        logging.info(f"Is namespace preserved = {self.preserve_namespace}")

    def __enter__(self):
        """ create a k8s namespace and set it up for runner """

        if not self.preserve_namespace:
            # create namespace
            cmd = f"kubectl create namespace {self.namespace_name}"
            Utils.run_cmd(cmd.split())

        try:
            # add rapidfortbot credentials
            docker_config_json_path = f"{os.environ.get('HOME')}/.docker/config.json"
            cmd = f"kubectl --namespace {self.namespace_name}"
            cmd += " create secret generic rf-regcred"
            cmd += f" --from-file=.dockerconfigjson={docker_config_json_path}"
            cmd += " --type=kubernetes.io/dockerconfigjson"
            Utils.run_cmd(cmd.split())

            # add tls certs
            cert_mgr_path = os.path.abspath(
                f"{self.script_dir}/../cert_managet_ns.yml")
            cmd = f"kubectl apply -f {cert_mgr_path} --namespace {self.namespace_name}"
            Utils.run_cmd(cmd.split())
        except subprocess.CalledProcessError as e:
            logging.info("`cert_managet_ns.yml` already present")

        # create tls certs for app
        Utils.generate_k8s_ssl_certs(
            self.image_script_dir,
            self.runtime_props.get("tls_certs", {}),
            self.namespace_name)

        # bring up the k8s resources
        self.create_k8s_cluster()

        # if health check script is available, use the health check script to wait
        # for cluster health
        if self.runtime_props.get("readiness_check_script", ""):
            try:
                self.run_readiness_check_script()
            except subprocess.CalledProcessError:
                self.cleanup()
                raise

        else:
            # waiting for pod to be ready
            logging.info("waiting for pod to be ready")
            wait_complete = False
            try:
                readiness_wait_deployments_suffix = self.runtime_props.get(
                    "readiness_wait_deployments_suffix")
                if not readiness_wait_deployments_suffix:
                    cmd = f"kubectl wait deployments {self.release_name}"
                    cmd += f" -n {self.namespace_name}"
                    cmd += " --for=condition=Available=True --timeout=20m"
                    Utils.run_cmd(cmd.split())
                else:
                    for deployment_suffix in readiness_wait_deployments_suffix:
                        cmd = f"kubectl wait deployments {self.release_name}-{deployment_suffix}"
                        cmd += f" -n {self.namespace_name}"
                        cmd += " --for=condition=Available=True --timeout=20m"
                        Utils.run_cmd(cmd.split())

                wait_complete = True
            except subprocess.CalledProcessError:
                logging.info(
                    "Wait deployment command failed, try waiting for pod-0")

            if not wait_complete:
                try:
                    readiness_wait_pod_name_suffix = self.runtime_props.get(
                        "readiness_wait_pod_name_suffix", ["0"])
                    for pod_name_suffix in readiness_wait_pod_name_suffix:
                        cmd = ""
                        if pod_name_suffix == "":
                            cmd += f"kubectl wait pods {self.release_name}"
                        else:
                            cmd += f"kubectl wait pods {self.release_name}-{pod_name_suffix}"
                        cmd += f" -n {self.namespace_name}"
                        cmd += " --for=condition=ready --timeout=20m"
                        Utils.run_cmd(cmd.split())
                    wait_complete = True
                except subprocess.CalledProcessError:
                    logging.info(
                        f"Wait for {pod_name_suffix} also failed, reraising error")
                    self.cleanup()
                    raise

        return {
            "namespace_name": self.namespace_name,
            "release_name": self.release_name,
            "image_tag_details": self.image_tag_details,
            "image_script_dir": self.image_script_dir,
            "runtime_props": self.runtime_props
        }

    def prepare_kubectl_cmd(self):
        """ Prepare kubectl command """
        cmd = f"kubectl run {self.release_name}"
        cmd += " --restart=Never --privileged"
        cmd += f" --namespace {self.namespace_name}"

        image_keys = self.runtime_props.get("image_keys", {})
        for repo_key, tag_details in self.image_tag_details.items():
            if repo_key in image_keys:
                repository_value = tag_details["repo_path"]
                tag_value = tag_details["tag"]

                cmd += f" --image {repository_value}:{tag_value}"

        for key, val in self.runtime_props.get(
                "kubectl_additional_params", {}).items():
            cmd += f" --{key}={val}"

        return cmd

    def prepare_helm_cmd(self):
        """ Prepare helm chart command """
        # Install helm
        override_file = f"{self.image_script_dir}/{self.runtime_props.get('override_file', 'overrides.yml')}"

        helm_repo = self.runtime_props.get('helm', {}).get('repo')
        helm_chart = self.runtime_props.get('helm', {}).get('chart')
        cmd = f"helm install {self.release_name}"
        cmd += f" {helm_repo}/{helm_chart}"
        cmd += f" --namespace {self.namespace_name}"

        image_keys = self.runtime_props.get("image_keys", {})
        for repo_key, tag_details in self.image_tag_details.items():
            if repo_key in image_keys:
                repository_key = image_keys[repo_key].get(
                    "repository", "image.repository")
                tag_key = image_keys[repo_key].get("tag", "image.tag")

                repository_value = tag_details["repo_path"]
                tag_value = tag_details["tag"]

                cmd += f" --set {repository_key}={repository_value}"
                cmd += f" --set {tag_key}={tag_value}"

        for key, val in self.runtime_props.get(
                "helm_additional_params", {}).items():
            cmd += f" --set {key}={val}"

        if self.command != Commands.LATEST_COVERAGE:
            cmd += f" -f {override_file}"

        return cmd

    def create_k8s_cluster(self):
        """ Bring up k8s resources. """
        use_helm = self.runtime_props.get(
            "use_helm", True)
        if use_helm:
            # add helm repo
            repo = self.runtime_props.get("helm", {}).get("repo")
            repo_url = self.runtime_props.get("helm", {}).get("repo_url")
            cmd = f"helm repo add {repo} {repo_url}"
            Utils.run_cmd(cmd.split())

            # upgrade helm
            cmd = "helm repo update"
            Utils.run_cmd(cmd.split())

            # Install helm
            self.create_helm_chart(self.prepare_helm_cmd())
        else:
            # bring up k8s cluster using kubectl
            self.create_kubectl_cluster(self.prepare_kubectl_cmd())

    @backoff.on_exception(backoff.expo, BaseException, max_time=300)
    def create_kubectl_cluster(self, cmd):
        """ Create k8s cluster using kubectl command. """
        logging.info(f"creating kubectl cluster with cmd: {cmd}")
        Utils.run_cmd(cmd.split())

    @backoff.on_exception(backoff.expo, BaseException, max_time=300)
    def create_helm_chart(self, cmd):
        """ Create helm chart """
        logging.info(f"cmd: {cmd}")
        Utils.run_cmd(cmd.split())

    def run_readiness_check_script(self):
        """ Run health check """
        readiness_check_script = self.runtime_props.get("readiness_check_script", "")
        if readiness_check_script is None:
            return

        logging.info(f"running readiness check script: {readiness_check_script}")
        timeout = self.runtime_props.get("readiness_check_timeout", 300)
        # run the health check script
        script_path = f"{self.image_script_dir}/{readiness_check_script}"
        cmd = f"bash {script_path} {self.namespace_name} {self.release_name}"
        Utils.run_cmd(cmd.split(), timeout=timeout)

    def cleanup(self):
        """ clean up k8s namespace """
        # log pods
        cmd = f"kubectl -n {self.namespace_name} get pods"
        Utils.run_cmd(cmd.split())

        cmd = f"kubectl -n {self.namespace_name} get pods --output=name"
        pods = subprocess.check_output(cmd.split())
        pod_list = pods.decode('utf-8').split()

        for pod in pod_list:
            cmd = f"kubectl -n {self.namespace_name} logs {pod}"
            cmd += " --all-containers --ignore-errors"
            Utils.run_cmd(cmd.split())

        cmd = f"kubectl -n {self.namespace_name} get svc"
        Utils.run_cmd(cmd.split())

        use_helm = self.runtime_props.get(
            "use_helm", True)
        if use_helm:
            # bring down helm install
            cmd = f"helm delete {self.release_name} --namespace {self.namespace_name}"
            Utils.run_cmd(cmd.split())
        else:
            cmd = f"kubectl delete pod {self.release_name} --namespace {self.namespace_name}"
            Utils.run_cmd(cmd.split())

        if not self.preserve_namespace:
            # delete the PVC associated
            cmd = "kubectl -n {self.namespace_name} delete pvc --all"
            Utils.run_cmd(cmd.split())

            # delete namespace
            cmd = f"kubectl delete namespace {self.namespace_name}"
            Utils.run_cmd(cmd.split())

    def __exit__(self, type, value, traceback):
        self.cleanup()
