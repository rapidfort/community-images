FROM joyzoursky/python-chromedriver:latest

WORKDIR /usr/workspace
RUN git clone https://github.com/joyzoursky/docker-python-chromedriver.git
RUN pip install pytest selenium
ADD https://raw.githubusercontent.com/rapidfort/community-images/main/community_images/common/scripts/bash_helper.sh /usr/workspace/bash_helper.sh

ADD ./entrypoint.sh /usr/workspace/entrypoint.sh
ADD ./pytest.ini /usr/workspace/pytest.ini

RUN mkdir -p /usr/workspace/selenium_tests
