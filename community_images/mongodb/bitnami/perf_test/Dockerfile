FROM openjdk:11

RUN git clone https://github.com/idealo/mongodb-performance-test.git

WORKDIR /mongodb-performance-test/latest-version

ADD ./entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]