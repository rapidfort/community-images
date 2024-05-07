FROM schukinpavel/python-chromedriver:latest

RUN mkdir -p /usr/workspace/selenium_tests
WORKDIR /usr/workspace
RUN pip install pytest selenium
ADD https://raw.githubusercontent.com/rapidfort/community-images/main/community_images/common/scripts/bash_helper.sh /usr/workspace/bash_helper.sh

ADD ./entrypoint.sh /usr/workspace/entrypoint.sh
ADD ./pytest.ini /usr/workspace/pytest.ini

RUN mkdir -p /usr/workspace/selenium_tests
