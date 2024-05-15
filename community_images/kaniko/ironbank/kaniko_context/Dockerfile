FROM alpine:3.12

COPY . .
RUN apk add --update nginx \
 && rm -rf /var/cache/apk/*

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]