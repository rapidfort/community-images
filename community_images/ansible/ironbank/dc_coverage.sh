#!/bin/bash

set -x
set -e

JSON_PARAMS="$1"

JSON=$(cat "$JSON_PARAMS")

echo "Json params for docker compose coverage = $JSON"
NAMESPACE=$(jq -r '.namespace_name' < "$JSON_PARAMS")
SCRIPTPATH=$(jq -r '.image_script_dir' < "$JSON_PARAMS")

# Extracting names for ansible and ubuntu_host
ANSIBLE_CONTAINER_NAME="${NAMESPACE}"-ansible-1
UBUNTU_CONTAINER_NAME="${NAMESPACE}"-ubuntu_host-1

# Obtaining the IP of the remote host (ubuntu_host container)
UBUNTU_HOST_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${UBUNTU_CONTAINER_NAME}")

# Setting up ubuntu_host for ssh login
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" apt-get update
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" apt-get install -y openssh-server
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" service ssh restart
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" bash -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'

# Generating ssh keys of ansible container for ssh login
docker exec -i -u root "${ANSIBLE_CONTAINER_NAME}" /bin/bash -c "cd /home/python && source python-env/bin/activate && ssh-keygen -q -t rsa -f /root/.ssh/id_rsa -N ''"
SSH_KEYS=$(docker exec -u root "${ANSIBLE_CONTAINER_NAME}" /bin/bash -c "cd /home/python && source python-env/bin/activate && cat /root/.ssh/id_rsa.pub")

# Copying the ssh keys into ubuntu_host
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" sh -c 'echo "$1" >> /root/.ssh/authorized_keys' -- "$SSH_KEYS"

# Confirming if transferring of ssh_keys is done successfully
docker exec -i -u root "${UBUNTU_CONTAINER_NAME}" bash -c 'cat ~/.ssh/authorized_keys'

# Initial Command
docker exec -i -u root "${ANSIBLE_CONTAINER_NAME}" /bin/bash -c "cd /home/python && source python-env/bin/activate && ansible --version"

# Creating and editing the inventory.ini for ansible
touch "$SCRIPTPATH"/inventory.ini

echo "[my_hosts]
$UBUNTU_HOST_IP" > "$SCRIPTPATH"/inventory.ini

# Copying the file into ansible container
docker cp "$SCRIPTPATH"/inventory.ini "${ANSIBLE_CONTAINER_NAME}":/home/python/inventory.ini

# Testing if inventory.ini is successfully transferred into ansible container by pinging the ubuntu_host
docker exec -i -u root "${ANSIBLE_CONTAINER_NAME}" /bin/bash -c "cd /home/python && source python-env/bin/activate && ansible my_hosts -m ping -i inventory.ini"

# Creating and editing playbook for ansible
touch "$SCRIPTPATH"/playbook.yml

echo "
- name: Uhost Management Playbook
  hosts: my_hosts
  become_user: root
  tasks:
   - name: Ping the host
     ping:
     tags: test-ping
   - name: Print message
     ansible.builtin.debug:
      msg: Hello Rapidfort
     tags: test-debug 
   - name: Update package lists (assuming apt-based system)
     apt:
      update_cache: yes
     tags: test-update-package    
   - name: Installing nginx
     apt:
      name: nginx
      state: present
     tags: test-application-installation 
 
   - name: Starting the nginx service
     service:
      name: nginx
      state: started
      enabled: true
     tags: test-start-nginx   
" > "$SCRIPTPATH"/playbook.yml

docker cp "$SCRIPTPATH"/playbook.yml "${ANSIBLE_CONTAINER_NAME}":/home/python/playbook.yml

# Creating and editing the ansible_coverage.sh containing all essential commands
touch "$SCRIPTPATH"/ansible_coverage.sh
chmod 777 "$SCRIPTPATH"/ansible_coverage.sh

VAULT_PASSWORD=$(openssl rand -base64 32)
touch "$SCRIPTPATH"/vault_password.txt

echo "$VAULT_PASSWORD" > "$SCRIPTPATH"/vault_password.txt

docker cp "$SCRIPTPATH"/vault_password.txt "${ANSIBLE_CONTAINER_NAME}":/home/python/vault_password.txt

echo "
cd /home/python
source python-env/bin/activate
ansible-playbook --version
ansible-playbook -i inventory.ini playbook.yml --syntax-check
ansible-playbook -i inventory.ini playbook.yml
ansible-community --version
ansible-inventory --version
ansible-inventory -i inventory.ini --graph
ansible-inventory -i inventory.ini --list
ansible-config --version
ansible-config init --disabled -t all > ansible.cfg
ansible-config dump --format json
ansible-connection --version
ansible-console --version || echo 0
ansible-doc --version
ansible-doc --list_files
ansible-doc -s copy
ansible-doc -t connection -F
ansible-galaxy --version
ansible-galaxy init myrole
ansible-galaxy search database
ansible-galaxy info mysql
ansible-test --version
ansible-vault --version
ansible-vault encrypt --vault-password-file=vault_password.txt playbook.yml
ansible-vault decrypt --vault-password-file=vault_password.txt playbook.yml
ansible --version
ansible-pull --version
" > "$SCRIPTPATH"/ansible_coverage.sh

docker cp "$SCRIPTPATH"/ansible_coverage.sh "${ANSIBLE_CONTAINER_NAME}":/home/python/ansible_coverage.sh

# Executing the ansible_coverage.sh
docker exec -i -u root "${ANSIBLE_CONTAINER_NAME}" /bin/bash -c "cd /home/python && source python-env/bin/activate && bash /home/python/ansible_coverage.sh"

# Cleanup
rm "$SCRIPTPATH"/ansible_coverage.sh
rm "$SCRIPTPATH"/playbook.yml
rm "$SCRIPTPATH"/inventory.ini
rm "$SCRIPTPATH"/vault_password.txt
