#!/bin/bash

# Update apt database
apt update

# Install openssh server and git
apt install openssh-server git -y

# Disable password based authentication for ssh server
echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Create directory required by sshd
mkdir /run/sshd

while true
do
  # Start ssh server in foreground
  /usr/sbin/sshd -dD
done

