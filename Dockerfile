FROM armhfbuild/debian:wheezy
MAINTAINER NGINX Docker Maintainers "docker-maint@nginx.com"
ENV NGINX_VERSION 1.13.4-1~wheezy

RUN apt-get update && \
    apt-get install -y wget debian-archive-keyring ca-certificates && \
    wget -O /tmp/nginx_signing.key "http://nginx.org/keys/nginx_signing.key" && \
    echo "deb-src http://nginx.org/packages/mainline/debian/ wheezy nginx" >> /etc/apt/sources.list && \
    apt-key add /tmp/nginx_signing.key && \
    apt-get update && \
    apt-get -y build-dep nginx

RUN cd /tmp \
 && apt-get source nginx \
 && cd nginx-1.13.4 \
 && dpkg-buildpackage -uc -b \
 && cd .. \
 && rm nginx-${NGINX_VERSION} -fR \
 && mv nginx_${NGINX_VERSION}_*.deb /
RUN dpkg -i /nginx_${NGINX_VERSION}_*.deb

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

EXPOSE 81

CMD ["nginx", "-g", "daemon off;"]
