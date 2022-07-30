""" K8s setup module """

import logging
import os
import subprocess


class K8sSetup:
    """ k8s setup context manager """
    def __init__(self, namespace_name, release_name, image_tag_list, runtime_props, image_script_dir):
        self.namespace_name = namespace_name
        self.release_name = release_name
        self.image_tag_list = image_tag_list
        self.runtime_props = runtime_props
        self.image_script_dir = image_script_dir
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

        # FIXME: add exponential backoff
        # Install helm
        override_file=f"{self.image_script_dir}/{self.runtime_props.get('override_file', 'overrides.yml')}"

        cmd=f"helm install {self.release_name}"
        cmd+=" bitnami/nats"
        cmd+=f" --namespace {self.namespace_name}"

        for i, image_key in enumerate(self.runtime_props.get("image_keys", [])):
            tag_key = image_key.get("tag")
            repository_key = image_key.get("repository")
            cmd+=f" --set {tag_key}={self.image_tag_list[(i*2)+1]}"
            cmd+=f" --set {repository_key}={self.image_tag_list[i*2]}"

        cmd+=f" -f {override_file}"
        subprocess.check_output(cmd.split())

        # waiting for pod to be ready
        logging.info("waiting for pod to be ready")
        cmd=f"kubectl wait deployments {self.release_name}"
        cmd+=f" -n {self.namespace_name}"
        cmd+=" --for=condition=Available=True --timeout=10m"
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
