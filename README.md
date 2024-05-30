# proxy nginx
* Nginx 소스코드를 다운받아서 컴파일 하여 설치합니다.
* Nginx 확장 모듈 소스코드를 다운받아서 컴파일 하여 설치합니다.


# build to docker image
```
$ docker build -t system/proxy:1.0.4 .
```

# build as 'build' stage only : option --target
```
docker build --target build -t system/proxy:1.0.4 .
```


# Dockerfile
* Dockerfile : Ubuntu 20.04 에 nginx-extras 1.18.0 버전 
    - nginx_headers-more-filter(3rd-party) : nginx-extras 에 포함되어 있음

* nginx1.22.0.Dockerfile : Ubuntu 23.04 에 nginx-extras 1.22.0 버전
    - ngx_http_proxy_module : nginx 1.19.3 부터 적용됨.
        - cookie 암호화 보안 flag 설정(SSL 사용시 Secure 적용됨)
    - ngx_http_headers_more_filter_module(3rd-party) : 컴파일해서 해서 추가
        - request header 에 Server 정보 제거
    - ndk_http_module(3rd-party) : 컴파일해서 해서 추가
        - ngx_http_lua_module 의존성 모듈
    - ngx_http_lua_module(3rd-party) : 컴파일 해서 추가
        - GraphQL introspection 기능 차단


# Nginx 1.22.0 modules
configure arguments: 

--with-cc-opt='-g -O2 -ffile-prefix-map=/build/nginx-TwrMyt/nginx-1.22.0=. -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -fdebug-prefix-map=/build/nginx-TwrMyt/nginx-1.22.0=/usr/src/nginx-1.22.0-1ubuntu3 -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' 
--with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -Wl,-z,relro -Wl,-z,now -fPIC' 
--prefix=/usr/share/nginx 
--conf-path=/etc/nginx/nginx.conf 
--http-log-path=/var/log/nginx/access.log 
--error-log-path=/var/log/nginx/error.log 
--lock-path=/var/lock/nginx.lock 
--pid-path=/run/nginx.pid 
--modules-path=/usr/lib/nginx/modules 
--http-client-body-temp-path=/var/lib/nginx/body 
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi 
--http-proxy-temp-path=/var/lib/nginx/proxy 
--http-scgi-temp-path=/var/lib/nginx/scgi 
--http-uwsgi-temp-path=/var/lib/nginx/uwsgi 
--with-compat 
--with-debug 
--with-pcre-jit 
--with-http_ssl_module 
--with-http_stub_status_module 
--with-http_realip_module 
--with-http_auth_request_module 
--with-http_v2_module 
--with-http_dav_module 
--with-http_slice_module 
--with-threads 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-geoip2 
--with-http_addition_module 
--with-http_flv_module 
--with-http_geoip_module=dynamic 
--with-http_gunzip_module 
--with-http_gzip_static_module 
--with-http_image_filter_module=dynamic 
--with-http_mp4_module 
--with-http_perl_module=dynamic 
--with-http_random_index_module 
--with-http_secure_link_module 
--with-http_sub_module 
--with-http_xslt_module=dynamic 
--with-mail=dynamic 
--with-mail_ssl_module 
--with-stream=dynamic 
--with-stream_geoip_module=dynamic 
--with-stream_ssl_module 
--with-stream_ssl_preread_module 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-headers-more-filter 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-auth-pam 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-cache-purge 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-dav-ext 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-ndk 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-echo 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-fancyindex 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/nchan 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/rtmp 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-uploadprogress 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-upstream-fair 
--add-dynamic-module=/build/nginx-TwrMyt/nginx-1.22.0/debian/modules/http-subs-filter
