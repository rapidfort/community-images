""" Utility methods """

import os
import shutil


class Utils:
    """ util class """
    @staticmethod
    def generte_ssl_certs(image_script_dir, tls_certs):
        """ generate ssl certs based on tls_certs object """

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

        cmd="openssl req -newkey rsa:4096"
        cmd+=" -x509 -sha256 -days 1 -nodes"
        cmd+=f" -out {cert_dir}/server.crt"
        cmd+=f" -keyout {cert_dir}/server.key"
        cmd+=" -subj \"/C=SI/ST=Ljubljana/L=Ljubljana/O=Security/OU=IT Department/CN=www.example.com\""

        return cert_dir
