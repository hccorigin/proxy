FROM ubuntu:20.04 as build_dynmod

ENV OS_RELEASE=ubuntu.20.04
ENV NGINX_VERSION=1.18.0
ENV NGINX_HOME=/etc/nginx
ENV NGINX_WEB_ROOT=/usr/share/nginx
ENV NGINX_MODULES_PATH=/usr/lib/nginx/modules
ENV NGINX_BUILD_PATH=/tmp/nginx
ENV DEP_LIB_PATH=${NGINX_BUILD_PATH}/libs
ENV DYN_MOD_PATH=${NGINX_BUILD_PATH}/modules
ENV PATH="$PATH:/etc/nginx/sbin"

RUN apt-get update && apt-get upgrade
RUN apt-get install -y automake autoconf m4 perl libtool  autotools-dev

# install util-tools
RUN apt-get install -y git wget curl

# C++ compiler for pcre
RUN apt-get install -y build-essential libreadline-dev libbz2-dev libpcre3 libpcre3-dev

RUN adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx

RUN cd /tmp && apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring \
    && curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null \
    && gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list \
    && echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/99nginx

# install firewall


# Install ModSecurity to connect to Nginx
RUN mkdir -p /tmp/nginx/libs && mkdir -p /tmp/nginx/modules

#===============================================================================================
## Compiling and installing Nginx's three dependency libraries

# 1. PCRE : Supports regular expressions. Required by the NGINX Core and Rewrite modules
# RUN cd /tmp/nginx/libs && wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz \
#    && tar -zxf pcre2-10.42.tar.gz
#    && cd pcre2-10.42 \
#    && ./configure \
#    && make && make install

#RUN cd /tmp/nginx/libs && git clone https://github.com/asmlib/pcre-8.36.git \
#    && cd pcre-8.36 && ./configure --prefix=/usr                     \
#            --docdir=/usr/share/doc/pcre-8.36 \
#            --enable-unicode-properties       \
#            --enable-pcre16                   \
#            --enable-pcre32                   \
#            --enable-pcregrep-libz            \
#            --enable-pcregrep-libbz2          \
#            --enable-pcretest-libreadline     \
#            --disable-static                 \ 
#    && make && make install    \
#    && mv -v /usr/lib/libpcre.so.* /lib  \
#    && ln -sfv ../../lib/$(readlink /usr/lib/libpcre.so) /usr/lib/libpcre.so

# 2. zlib : Supports header compression. Required by the NGINX Gzip module.
RUN cd /tmp/nginx/libs && wget http://zlib.net/zlib-1.3.tar.gz \
    && tar -zxf zlib-1.3.tar.gz \
    && cd zlib-1.3 \
    && ./configure \
    && make && make install
# 3. OpenSSL – Supports the HTTPS protocol. Required by the NGINX SSL module and others.
RUN cd /tmp/nginx/libs && wget https://www.openssl.org/source/openssl-1.1.1v.tar.gz \
    && tar -zxf openssl-1.1.1v.tar.gz \
    && cd openssl-1.1.1v \
    && ./config --prefix=/etc/nginx/ssl --openssldir=/etc/nginx/ssl shared zlib  \
    && make && make install


#===============================================================================================
## Dynamic module 

##- Lua Jit
# RUN cd /tmp/nginx/modules && git clone https://github.com/openresty/luajit2.git  \
#     && cd luajit2 \
#     && make && make install \
#     && export LUAJIT_LIB=/etc/nginx/lib \
#     && export LUAJIT_INC=/etc/nginx/include/luajit-2.1
##- Lua script
# RUN cd /tmp/nginx/modules && git clone https://github.com/openresty/lua-nginx-module.git

#- Routing Table Mantanence Protocol
# RUN cd /tmp/nginx/modules && git clone https://github.com/arut/nginx-rtmp-module.git

#- add/remove items from Header : for deleting key-val like 'Server: nginx' from Http Header
# RUN cd /tmp/nginx/modules && git clone https://github.com/openresty/headers-more-nginx-module.git
#- nginx_cookie_flag_module :
RUN cd /tmp/nginx/modules && git clone https://github.com/AirisX/nginx_cookie_flag_module.git

#===============================================================================================
## External Static module

#===============================================================================================
## Compiling and Installing Nginx
RUN cd /tmp/nginx && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure \
        --prefix=/etc/nginx \
#        --sbin-path=/etc/nginx/nginx/nginx \
#        --conf-path=/etc/nginx/nginx/nginx.conf \
        --pid-path=/etc/nginx/nginx.pid \
        --modules-path=/etc/nginx/modules \
        --user=nginx \
        --group=nginx \
# Configuring NGINX GCC Options(compiler and linker)
        --with-cc-opt='-g -O2 -fdebug-prefix-map=/tmp/nginx/nginx-${NGINX_VERSION}=. -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' \
        --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC' \
#        --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC,/etc/nginx/lib' \
# dependency libraries for Nginx binary and configuration file
        --with-pcre \
#        --with-pcre=../libs/pcre-8.36 \
        --with-zlib=../libs/zlib-1.3 \
        --with-openssl=../libs/openssl-1.1.1v \
        --with-pcre-jit \
        --with-debug  \
        --with-compat  \
# Log path
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
# modules built by default
#        --with-http_access_module \
#        --with-http_auth_basic_module \
#        --with-http_autoindex_module \
#        --with-http_browser_module \
#        --with-http_charset_module \
#        --with-http_empty_gif_module \
#        --with-http_fastcgi_module \
#        --with-http_geo_module \
#        --with-http_gzip_module \
#        --with-http_limit_conn_module \
#        --with-http_limit_req_module \
#        --with-http_map_module \
#        --with-http_memcached_module \
#        --with-http_proxy_module \
#        --with-http_referer_module \
#        --with-http_rewrite_module \
#        --with-http_scgi_module \
#        --with-http_ssi_module \
#        --with-http_split_clients_module \
#        --with-http_upstream_hash_module \
#        --with-http_upstream_ip_hash_module \
#        --with-http_upstream_keepalive_module \
#        --with-http_upstream_least_conn_module \
#        --with-http_upstream_zone_module \
#        --with-http_userid_module \
#        --with-http_uwsgi_module \
# modules Not built by default
#        --with-http_ssl_module \
#        --with-http_stub_status_module  \
#        --with-http_realip_module  \
#        --with-http_auth_request_module  \
#        --with-http_v2_module  \
#        --with-http_dav_module  \
#        --with-http_slice_module  \
#        --with-threads  \
#        --with-http_addition_module  \
#        --with-http_flv_module  \
#        --with-http_gunzip_module  \
#        --with-http_gzip_static_module  \
#        --with-http_mp4_module  \
#        --with-http_random_index_module  \
#        --with-http_secure_link_module  \
#        --with-http_sub_module  \
## thiese dynamic modules : install .so using apt-get, and then loading them from config file. 
#        --with-http_geoip_module=dynamic  \
#        --with-http_image_filter_module=dynamic  \
#        --with-http_perl_module  \
#        --with-http_xslt_module  \
# dynamic modules : mail, stream, geoip, image_filter, perl and xslt modules
#        --with-mail=dynamic \
#        --with-mail_ssl_module \
#        --with-stream=dynamic \
#        --with-stream_ssl_module \
#        --with-stream_ssl_preread_module \
# dynamic modules for compiling the source code        
#        --add-dynamic-module=../modules/headers-more-nginx-module \
        --add-dynamic-module=../modules/nginx_cookie_flag_module \
#        --add-module=/usr/build/nginx-rtmp-module \
#        --add-dynamic-module=/usr/build/3party_module \
    && make && make install


# NGINX 1.18.0-----------------------------------------------------------------------------------------------
FROM ubuntu:20.04 as dist1.18.0

LABEL maintainer="HYUNDAICARD Origin Operation Team <won,wooseok@hcs.com>"

ENV OS_RELEASE=ubuntu.20.04
ENV NGINX_VERSION=1.18.0
ENV NGINX_HOME=/etc/nginx 
ENV NGINX_MODULES=/usr/lib/nginx/modules
ENV NGINX_PREFIX=/usr/share/nginx
ENV PATH="$PATH:/etc/nginx/sbin"


# utility
RUN apt-get update && apt-get upgrade
RUN apt-get install -y curl gnupg1
RUN adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx

## Refer to https://www.nginx.com/resources/wiki/start/topics/tutorials/install/
# 0. apt source list for nignx
RUN  echo "deb https://nginx.org/packages/ubuntu/ focal nginx" | tee /etc/apt/sources.list.d/nginx.list \
    && echo "deb-src https://nginx.org/packages/ubuntu/ focal nginx" | tee /etc/apt/sources.list.d/nginx.list

# 1.Update the Ubuntu repository information:
#- GPG key 오류나면 오류메시지에 있는 키값을 --recv-keys 옵션에 적는다.
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 'ABF5BD827BD9BF62'  && apt-get update

# 2.Install the package:
RUN apt-get install -y nginx

# 3.Verify the installation:
RUN nginx -v

# 4. install nginx_extras : 
#** 10-mod-http-ndk.conf          50-mod-http-echo.conf        50-mod-http-headers-more-filter.conf  50-mod-http-subs-filter.conf      
#** 50-mod-http-auth-pam.conf     50-mod-http-fancyindex.conf  50-mod-http-uploadprogress.conf       50-mod-nchan.conf
#** 50-mod-http-cache-purge.conf  50-mod-http-geoip.conf       50-mod-http-lua.conf                  50-mod-http-upstream-fair.conf    
#** 50-mod-http-dav-ext.conf      50-mod-http-geoip2.conf      50-mod-http-perl.conf                  
RUN apt-get install -y nginx-extras


# Copy modules
# COPY --from=build_dynmod  /tmp/nginx/nginx-${NGINX_VERSION}/objs/ngx_http_headers_more_filter_module.so ${NGINX_MODULES}
COPY --from=build_dynmod  /tmp/nginx/nginx-${NGINX_VERSION}/objs/ngx_http_cookie_flag_filter_module.so ${NGINX_MODULES}

# set stdout, stderr to log file
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log



EXPOSE 80

STOPSIGNAL SIGQUIT


CMD ["nginx", "-g", "daemon off;"]
#ENTRYPOINT tail -f /dev/null


# NGINX 1.22.0-----------------------------------------------------------------------------------------------
FROM ubuntu:23.04 as dist1.22.0

LABEL maintainer="HYUNDAICARD Origin Operation Team <won,wooseok@hcs.com>"
# ubuntu.22.04 LTS(Jammy Jellyfish)
ENV OS_RELEASE=ubuntu.22.04
ENV NGINX_VERSION=1.22.0
ENV NGINX_HOME=/etc/nginx 
ENV NGINX_MODULES=/usr/lib/nginx/modules
ENV NGINX_PREFIX=/usr/share/nginx
ENV PATH="$PATH:/etc/nginx/sbin"


# utility
RUN apt update
#RUN apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring 
#RUN adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx

## Refer to https://www.nginx.com/resources/wiki/start/topics/tutorials/install/

# 0.signing
#- GPG key 오류나면 오류메시지에 있는 키값을 --recv-keys 옵션에 적는다.
#RUN  curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
#     | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
# 0. apt source list for nignx
#RUN  echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \

# 2.Install the package:
RUN apt install -y nginx

# 3.Verify the installation:
RUN nginx -v

EXPOSE 80

STOPSIGNAL SIGQUIT


CMD ["nginx", "-g", "daemon off;"]
#ENTRYPOINT tail -f /dev/null

