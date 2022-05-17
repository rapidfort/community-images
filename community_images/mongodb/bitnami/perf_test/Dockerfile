FROM openjdk:11

RUN git clone https://github.com/idealo/mongodb-performance-test.git

WORKDIR /mongodb-performance-test/latest-version

ENTRYPOINT [ \
    "sh", "-c", "java", \
    "-jar mongodb-performance-test.jar", \
    "-m ${MONGODB_OPERATION}", \
    "-o 1000000 -t 100 -db test -c perf", \ 
    "-port ${MONGODB_PORT}", \
    "-h \"${MONGODB_HOST}\"", \
    "-u root -p ${MONGODB_ROOT_PASSWORD} -adb admin" \
     ]
