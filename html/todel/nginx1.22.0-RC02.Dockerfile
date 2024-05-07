FROM ubuntu:23.04 as build-dynmod

ENV NGINX_VERSION=1.22.0
ENV NGINX_HOME=/etc/nginx 
ENV NGINX_MODULES=/usr/lib/nginx/modules
ENV NGINX_PREFIX=/usr/share/nginx
ENV NGINX_BUILD=/usr/share/nginx/build-modules
ENV NGINX_LUA_MOD_VER=0.10.25

RUN apt update \
    && apt install -y git wget curl \
# development tools    
    && apt-get install -y build-essential libreadline-dev libbz2-dev libpcre3 libpcre3-dev

# Account nginx 
#    && adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx \

# NGINX : install
#    && apt-get install -y nginx \
# RUN nginx -V

#==========================================================================
# START BUILDING
RUN mkdir -p $NGINX_BUILD
# 1. PCRE : Supports regular expressions. Required by the NGINX Core and Rewrite modules
RUN cd $NGINX_BUILD && wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz \
    && tar -zxf pcre2-10.42.tar.gz \
    && cd pcre2-10.42 \
    && ./configure --prefix=/usr/local \
    && make && make install

# 2. zlib : Supports header compression. Required by the NGINX Gzip module.
RUN cd $NGINX_BUILD && wget http://zlib.net/zlib-1.3.tar.gz \
    && tar -zxf zlib-1.3.tar.gz \
    && cd zlib-1.3 \
    && ./configure \
    && make && make install

# 3. OpenSSL – Supports the HTTPS protocol. Required by the NGINX SSL module and others.
RUN cd $NGINX_BUILD && wget https://github.com/openssl/openssl/releases/download/openssl-3.1.2/openssl-3.1.2.tar.gz \
    && tar -zxf openssl-3.1.2.tar.gz \
    && cd openssl-3.1.2 \
    && ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib  \
    && make && make install
ENV PATH=/usr/local/ssl/bin:$PATH

# 4.LuaJIT2 : required by lua-nginx-module
RUN cd $NGINX_BUILD && wget https://github.com/openresty/luajit2/archive/refs/tags/v2.1-20230410.tar.gz -O luajit2-2.1-20230410.tar.gz \
    && tar zxf luajit2-2.1-20230410.tar.gz \
    && cd luajit2-2.1-20230410 \
    && make && make install
ENV LUAJIT_LIB=/usr/local/lib
ENV LUAJIT_INC=/usr/local/include/luajit-2.1

# 5. NDK : required by lua-nginx-module and more moredules
RUN cd $NGINX_BUILD && wget https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v0.3.2.tar.gz -O ngx_devel_kit-0.3.2.tar.gz \
    && tar zxf ngx_devel_kit-0.3.2.tar.gz
    
# 6. lua-nginx-module : compatible nginx 1.21.4
###- Nginx 호환버전 확인 : https://github.com/openresty/lua-nginx-module#nginx-compatibility 
RUN cd $NGINX_BUILD && wget https://github.com/openresty/lua-nginx-module/archive/refs/tags/v${NGINX_LUA_MOD_VER}.tar.gz -O lua-nginx-module-${NGINX_LUA_MOD_VER}.tar.gz \
    && tar zxf lua-nginx-module-${NGINX_LUA_MOD_VER}.tar.gz

# 7. ngx_http_headers_more_filter_module : 
RUN cd $NGINX_BUILD && wget https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.34.tar.gz -O headers-more-nginx-module-0.34.tar.gz \
    && tar zxf headers-more-nginx-module-0.34.tar.gz

#######################################################################################
# 8. Compiling Dynamic modules of Nginx
RUN cd $NGINX_BUILD && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf nginx-${NGINX_VERSION}.tar.gz \

# Build configure environment && compile and install nginx
#### ld option 에 LuaJit libraray path 를 지정해준다(/usr/local/lib/)
    && cd nginx-${NGINX_VERSION} \
    && ./configure \
        --prefix=/usr/share/nginx \
        --with-ld-opt="-Wl,-rpath,${LUAJIT_LIB}" \
        --with-pcre=${NGINX_BUILD}/pcre2-10.42 \
        --with-zlib=${NGINX_BUILD}/zlib-1.3 \
        --with-openssl=${NGINX_BUILD}/openssl-3.1.2 \
        --with-pcre-jit \
        --with-debug  \
        --with-compat  \
        --add-dynamic-module=${NGINX_BUILD}/headers-more-nginx-module-0.34 \
        --add-dynamic-module=${NGINX_BUILD}/ngx_devel_kit-0.3.2 \
        --add-dynamic-module=${NGINX_BUILD}/lua-nginx-module-${NGINX_LUA_MOD_VER} \
    && make modules
#    && cp objs/*.so ${NGINX_MODULES}
#######################################################################################


# 9. OpenResty Official : required by lua-nginx-module
RUN cd $NGINX_BUILD && wget https://openresty.org/download/openresty-1.21.4.2.tar.gz \
    && tar zxf openresty-1.21.4.2.tar.gz \
    && cd openresty-1.21.4.2 \
    && ./configure -j2 --with-openssl=$NGINX_BUILD/openssl-3.1.2 \
    && make -j2 && make install
ENV PATH=/usr/local/openresty/bin:$PATH

# 10. lua-resty-core & lua-resty-lrucache : required by lua-nginx-module
RUN cd $NGINX_BUILD && wget https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.27.tar.gz -O lua-resty-core-0.1.27.tar.gz \
    && tar zxf lua-resty-core-0.1.27.tar.gz \
    && cd lua-resty-core-0.1.27 \
    && make && make install \
    && cd $NGINX_BUILD && wget https://github.com/openresty/lua-resty-lrucache/archive/refs/tags/v0.13.tar.gz -O lua-resty-lrucache-0.13.tar.gz \
    && tar zxf lua-resty-lrucache-0.13.tar.gz \
    && cd lua-resty-lrucache-0.13 \
    && make && make install
#==========================================================================
# 11. delete all modules which no more needed
#    && rm -rf $NGINX_BUILD \

# 12. set stdout and stderror to nginx log files 
#    && ln -sf /dev/stdout /var/log/nginx/access.log \
#    && ln -sf /dev/stderr /var/log/nginx/error.log



FROM nginx:1.22.0 as dist1.22.0

LABEL maintainer="HYUNDAICARD Origin Operation Team <won,wooseok@hcs.com>"
# ubuntu.22.04 LTS(Jammy Jellyfish)
ENV OS_RELEASE=ubuntu.22.04
ENV NGINX_VERSION=1.22.0
ENV NGINX_HOME=/etc/nginx 
ENV NGINX_MODULES=/usr/lib/nginx/modules
ENV NGINX_PREFIX=/usr/share/nginx
ENV PATH="$PATH:/etc/nginx/sbin"

COPY --from=build_dynmod $NGINX_BUILD/nginx-${NGINX_VERSION}/objs/*.so ${NGINX_MODULES}

EXPOSE 80

STOPSIGNAL SIGQUIT

#ENTRYPOINT tail -f /dev/null
CMD ["nginx", "-g", "daemon off;"]