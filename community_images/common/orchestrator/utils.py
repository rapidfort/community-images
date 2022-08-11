""" Utility methods """

#import logging
import os
import shutil
import subprocess
import yaml
from yaml import CLoader as Loader, CDumper as Dumper

class Utils:
    """ util class """

    CERT_YML="""
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: localhost-server
spec:
  secretName: localhost-server-tls
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  subject:
    organizations:
      - rapidfort
  commonName: localhost
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
    - client auth
  issuerRef:
    name: ci-ca-issuer
    kind: Issuer
    group: cert-manager.io
"""


    @staticmethod
    def generate_ssl_certs(image_script_dir, tls_certs):
        """ generate ssl certs based on tls_certs object """

        if not image_script_dir or not tls_certs:
            return None

        generate_certs = tls_certs.get("generate", False)
        if not generate_certs:
            return None

        cert_dir = tls_certs.get("out_dir", "certs")
        cert_path = os.path.abspath(os.path.join(image_script_dir, cert_dir))

        # remove existing dir
        if os.path.exists(cert_path) and os.path.isdir(cert_path):
            shutil.rmtree(cert_path)

        # create new dir
        os.makedirs(cert_path, exist_ok=True)

        common_name = tls_certs.get("common_name", "localhost")
        cmd=["openssl", "req", "-newkey", "rsa:4096"]
        cmd+=["-x509", "-sha256", "-days", "3650", "-nodes"]
        cmd+=["-out", f"{cert_path}/server.crt"]
        cmd+=["-keyout", f"{cert_path}/server.key"]
        cmd+=["-subj", f"/C=US/ST=CA/L=Sunnyvale/O=RapidFort/OU=Community Images/CN={common_name}"]
        subprocess.check_output(cmd)

        return cert_path

    @classmethod
    def generate_k8s_ssl_certs(cls ,image_script_dir, tls_certs, namespace):
        """ generates ssl certs for k8s and mount to secret using cert manager """

        if not image_script_dir or not tls_certs or not namespace:
            return False

        generate_certs = tls_certs.get("generate", False)
        if not generate_certs:
            return False

        common_name =  tls_certs.get("common_name", "localhost")
        cert_dict = yaml.load(cls.CERT_YML, Loader)
        cert_dict["metadata"]["name"] = f"{common_name}-cert"
        cert_dict["spec"]["commonName"] = common_name
        cert_dict["spec"]["secretName"] = tls_certs.get("secret_name")

        cert_yaml_path = os.path.abspath(os.path.join(image_script_dir, "tls_certs.yml"))
        with open(cert_yaml_path, "w", encoding="UTF-8") as yaml_stream:
            yaml.dump(cert_dict, yaml_stream, Dumper)

        cmd=f"kubectl apply -f {cert_yaml_path} --namespace {namespace}"
        subprocess.check_output(cmd)
        return True
