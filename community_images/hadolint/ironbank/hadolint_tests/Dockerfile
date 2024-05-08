# DL3029
FROM node:latest

# DL3000
WORKDIR /app

# DL3001
RUN apt-get remove -y ssh vim shutdown service ps free top kill mount ifconfig

# DL3002
USER node

# DL3003
RUN cd /opt/app

# DL3004
RUN sudo apt-get install -y nodejs

# DL3005
RUN apt-get upgrade

# DL3006
FROM node:latest

# DL3007
FROM node:latest

# DL3008
RUN apt-get install nodejs=14.16.1

# DL3009
RUN apt-get clean

# DL3010
RUN tar -xvf archive.tar.gz

# DL3011
EXPOSE 8080

# DL3012
MAINTAINER John Doe

# DL3013
RUN pip install flask==1.1.2

# DL3014
RUN apt-get install -y nodejs

# DL3015
RUN apt-get install -y nodejs --no-install-recommends

# DL3016
RUN npm install express

# DL3017
RUN apk upgrade

# DL3018
RUN apk add nodejs=14.16.1

# DL3019
RUN apk add --no-cache nodejs

# DL3020
ADD ./file.tar.gz /app

# DL3021
COPY file1.txt file2.txt /app/

# DL3022
COPY --from=node:latest /app /app

# DL3023
COPY --from=node:latest /app /app

# DL3024
FROM node AS builder
FROM node AS builder

# DL3025
CMD ["node", "app.js"]

# DL3026
FROM registry.example.com/node:latest

# DL3027
RUN apt install nginx

# DL3028
RUN gem install rails:6.1.0



# DL3030
RUN yum install <package>

# DL3031
RUN yum update

# DL3032
RUN yum install <package>
RUN yum clean

# DL3033
RUN yum install -y <package>-1.0.0

# DL3034
RUN zypper install nodejs

# DL3035
RUN zypper update

# DL3036
RUN zypper install nodejs
RUN zypper clean

# DL3037
RUN zypper install -y nodejs=14.16.1

# DL3038
RUN dnf install nodejs

# DL3039
RUN dnf update

# DL3040
RUN dnf install nodejs
RUN dnf clean all

# DL3041
RUN dnf install -y nodejs-14.16.1

# DL3042
RUN pip install flask --no-cache-dir

# DL3043
ONBUILD RUN npm install

# DL3044
ENV ENV_VAR $ENV_VAR

# DL3045
COPY index.html .

# DL3046
RUN useradd -u 1000 user

# DL3047
RUN wget http://example.com/file

# DL4000
MAINTAINER John Doe

# DL4001
RUN apt-get install -y curl wget \
    && apt-get clean

# DL4003
CMD ["npm", "start"]
CMD ["node", "app.js"]

# DL4004
ENTRYPOINT ["npm", "start"]
ENTRYPOINT ["node", "app.js"]

# DL4005
SHELL ["/bin/bash", "-c"]

# DL4006
SHELL ["bash", "-o", "pipefail", "-c"]

# SC1000
RUN echo "Hello \$World"

# SC1001
RUN echo "This \c will be a regular 'c' in this context."

# SC1007
RUN var= 42

# SC1010
RUN if true then echo "Hello"; fi

# SC1018
RUN echo "This is a unicode non-breaking space."

# SC1035
RUN echo "You need a space here"

# SC1045
RUN foo &; bar

# SC1065
RUN function_name() { echo "$1"; }

# SC1066
RUN $var = "value"

# SC1068
RUN var= 42

# SC1077
RUN echo 'This ` will slant left'

# SC1078
RUN echo "Did you forget to close this double-quoted string?"

# SC1079
RUN echo "This is actually an end quote, but due to next char, it looks suspect".

# SC1081
RUN if True; then echo "Hello"; fi

# SC1083
RUN echo {/}

# SC1086
RUN for $i in {1..5}; do echo $i; done

# SC1087
RUN array=("a" "b" "c")
RUN echo $array[0]

# SC1095
RUN function_name () { echo "Hello"}

# SC1097
RUN echo $((2 + 2))

# SC1098
RUN eval "a=(b)"

# SC1099
# This is a comment

# SC2002
RUN cat file | grep pattern
RUN cmd < file | grep pattern

# SC2015
RUN if A && B || C; then echo "True" fi

# SC2026
RUN echo "The answer is \$((1+1))"

# SC2028
RUN echo "Escape sequences won't be expanded\n"

# SC2035
RUN rm ./-file

# SC2039
RUN echo $undefined_variable

# SC2046
RUN echo $var

# SC2086
RUN echo $var

# SC2140
RUN echo "A"B"C"

# SC2154
RUN echo $var

# SC2155
RUN function_name() { local var var="Hello" echo $var }

# SC2164
RUN cd /path/to/directory || exit
