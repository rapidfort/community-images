# This is a simple Dockerfile with potential issues for Hadolint

# Base Image Issues (DL3000s)
# Using 'latest' tag (DL3006)
FROM ubuntu:latest  
# Consider using a specific version

# Security Issues (DL3000s)
# Unnecessary RUN (DL3008)
RUN echo "Hello, world!"  
# Remove unnecessary commands

# Using 'sudo' (DL3004)
RUN sudo apt-get install some-package  
# Avoid 'sudo' inside container

# Ignoring package manager warnings (DL3013)
RUN apt-get install -y python3 > /dev/null 2>&1  
# Suppress warnings

# Building as root (DL3011)
# Consider using a non-root user for the build stage

# Package Management Issues (DL3020s)
# Shellcheck warning: Use apt-get install <package>=<version> (SC2102)
RUN apt-get install python3  
# Missing version specification

# Installing unnecessary packages (DL3022)
RUN apt-get install -y vim nano  
# Only install what's needed

# Using wildcard characters in COPY (DL3032)
COPY *requirements.txt .  
# Be specific with file paths

# WORKDIR Issues (DL3040s)
# Copy without WORKDIR (DL3045)
COPY requirements.txt .  
# Set WORKDIR before copying

# Conflicting WORKDIR instructions (DL3042)
WORKDIR /app
RUN mkdir /app/data  # Avoid conflicting directory creation

# CMD/ENTRYPOINT Issues (DL3000s)
# CMD without arguments (DL3002)
CMD ["python"]  
# Specify the script to run

# ENTRYPOINT without arguments (DL3001)
ENTRYPOINT ["python"]  
# Specify the script path and arguments

# Missing arguments in CMD/ENTRYPOINT (DL3009)
CMD ["python", "myscript.py"]  
# Missing required arguments

# Environment Variable Issues (DL3050s)
# Unquoted environment variable (SC2153)
ENV MYVAR=This is a variable  
# Quote environment variables

# Using single quotes for environment variables (SC2152)
ENV ANOTHER_VAR='This is another variable'  
# Use double quotes

# Shellcheck Warning: Avoid echo (SC2164)
RUN echo "Setting environment variable"
ENV ANOTHER_VAR2=value  
# Prefer setting directly

# Build Stage Issues (Multi-Stage Builds)
# Copying unnecessary files in the final stage (SC2150)
FROM python:3.9-slim  
# Use a slimmer base image for final stage
COPY requirements.txt ./requirements.txt  
# Only copy necessary files

# Including unnecessary layers (SC2151)
RUN pip install -r requirements.txt  
# Move this to a previous stage

# Other Issues
# Shellcheck warning: Use [[ ]] for conditionals (SC2155)
RUN if [[ $VAR == "true" ]]; then echo "Variable is true"; fi

# Insufficient logging (DL3016)
RUN some_command  
# Add logging for troubleshooting

# Hardcoded secrets (DL3017)
ENV SECRET_KEY="my_secret_key"  
# Use environment variables from outside

# Missing healthcheck (DL3018)
# Consider adding a healthcheck for container monitoring

# Using absolute paths in RUN (DL3038)
RUN /bin/bash -c "some_command"  
# Use relative paths

# Shellcheck warning: Use $(command) for subshells (SC2004)
RUN echo $(ls)  
# Prefer backticks for simpler commands

# This list is not exhaustive. Refer to Hadolint documentation for more.
