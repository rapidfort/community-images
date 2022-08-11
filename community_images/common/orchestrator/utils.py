""" Utility methods """

import logging
import os
import shutil
import subprocess

class Utils:
    """ util class """
    @staticmethod
    def generte_ssl_certs(image_script_dir, tls_certs):
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

        cmd=["openssl", "req", "-newkey", "rsa:4096"]
        cmd+=["-x509", "-sha256", "-days", "3650", "-nodes"]
        cmd+=["-out", f"{cert_path}/server.crt"]
        cmd+=["-keyout", f"{cert_path}/server.key"]
        cmd+=["-subj", "/C=SI/ST=Ljubljana/L=Ljubljana/O=Security/OU=IT Department/CN=www.example.com"]
        subprocess.check_output(cmd)

        return cert_path
