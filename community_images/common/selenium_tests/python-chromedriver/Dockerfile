FROM joyzoursky/python-chromedriver:latest

WORKDIR /usr/workspace
RUN git clone https://github.com/joyzoursky/docker-python-chromedriver.git
RUN pip install pytest selenium
ADD ./bash_helper.sh /usr/workspace/bash_helper.sh

ADD ./entrypoint.sh /usr/workspace/entrypoint.sh

RUN mkdir -p /usr/workspace/selenium_tests
