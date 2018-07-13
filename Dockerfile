#++++++++++++++++++++++++++++++++++++++++++++++++
# Docker file for mrmainnet/nginx-plus:1.13.0
#++++++++++++++++++++++++++++++++++++++++++++++++

FROM centos:latest
MAINTAINER vy.nguyen (ntv1090@gmail.com)

ENV NGINX_VERSION 1.13.0

WORKDIR /usr/local/src
RUN mkdir -p /etc/ssl/nginx
ADD nginx-repo.crt /etc/ssl/nginx/
ADD nginx-repo.key /etc/ssl/nginx/
RUN yum install ca-certificates wget -y

RUN set -xv \
	&& yum install epel-release -y \
	&& wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/nginx-plus-7.4.repo \
	&& yum clean all && yum install nginx-plus -y \
	&& yum install nginx-plus-module-* -y -x nginx-plus-module-wallarm

RUN set -xv \
	&& yum -y install gcc gcc-c++ make zlib-devel pcre-devel openssl-devel wget make git lua-devel \
	&& git clone https://github.com/openresty/lua-nginx-module \
	&& git clone https://github.com/kyprizel/testcookie-nginx-module \
	&& git clone https://github.com/openresty/headers-more-nginx-module \
	&& wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
	&& tar xzvf nginx-${NGINX_VERSION}.tar.gz \
	&& cd nginx-${NGINX_VERSION} \
	&& ./configure --with-compat --add-dynamic-module=../testcookie-nginx-module --add-dynamic-module=../lua-nginx-module --add-dynamic-module=../headers-more-nginx-module \
	&& make modules \
	&& cp objs/*.so /etc/nginx/modules/

RUN ln -sf /usr/share/zoneinfo/Asia/Saigon /etc/localtime && rm /usr/local/src/* -rf && rm /var/cache/yum/* -rf
STOPSIGNAL SIGTERM
CMD ["/sbin/nginx" , "-g" , "daemon off;"]
