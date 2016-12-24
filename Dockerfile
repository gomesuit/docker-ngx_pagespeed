FROM centos:7

EXPOSE 80

ENV NPS_VERSION 1.11.33.4
ENV NGINX_VERSION 1.11.7
# ENV PATH /usr/local/nginx/sbin/:$PATH

RUN yum install -y wget gcc-c++ pcre-devel zlib-devel make unzip openssl-devel && \
    yum clean all

RUN useradd -r nginx

RUN cd /tmp \
    && wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip \
    && unzip release-${NPS_VERSION}-beta.zip \
    && cd ngx_pagespeed-release-${NPS_VERSION}-beta/ \
    && wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz \
    && tar -xzvf ${NPS_VERSION}.tar.gz \
    && cd /tmp \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -xvzf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION}/ \
    && ./configure \
    --prefix=/etc/nginx                   \
    --sbin-path=/usr/sbin/nginx           \
    --conf-path=/etc/nginx/nginx.conf     \
    --pid-path=/var/run/nginx.pid         \
    --lock-path=/var/run/nginx.lock       \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \    
    --add-module=/tmp/ngx_pagespeed-release-${NPS_VERSION}-beta \
    --with-http_gzip_static_module        \
    --with-http_stub_status_module        \
    --with-http_ssl_module                \
    --with-pcre                           \
    --with-file-aio                       \
    --with-http_realip_module             \
    --without-http_scgi_module            \
    --without-http_uwsgi_module           \
    --without-http_fastcgi_module \
    && make \
    && make install \
    && rm -frdv /tmp/*

# COPY ./nginx.conf /usr/local/nginx/conf/nginx.conf
COPY ./nginx.conf /etc/nginx/nginx.conf

# RUN ln -sf /dev/stderr /usr/local/nginx/logs/error.log
# RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
RUN ln -sf /dev/stdout /var/log/nginx/access.log

CMD ["nginx", "-g", "daemon off;"]

