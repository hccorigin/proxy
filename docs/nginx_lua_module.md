# lua nginx module
* 이 모듈은 실시간Lua번역기인 LuaJIT(Just In Time) 2.0/2.1 을 Nginx 에 탑재한다.
* 이 모듈은 OpenResty 의 핵심 Components 이다.

## [OpenResty](https://openresty.org/en/)
* OpenResty 는 Nginx core, LuaJIT 의 enhanced versions, Lua libraries, 다량의 3rd-party Nginx modules 과 이들의 외부 의존적인 것들을 모두 통합한 잘 만들어진 web platform 이다. 
* 이것은 개발자들이 쉽게 Nginx 기반에서 scalable web applicatios, web services, dynamic web gateways 를 빌드하게 도와준다.
* 다양한 Nginx modules 을 이용함에 있어, OpenResty 는 아주 효과적으로 Nginx server 를 강력한 Web app server로 만들수 있다.
* 개발자들은 내장된 nginx C modules 과 Lua modules 을 조작 하거나 10k~1000k 연결을 핸들링 하는 고성능의 web application을 구축하는데 Lua programming language 를 사용할 수가 있다.
* OpenResty는 Nginx Server 에서 완벽한 server-side web app 을 실행하는게 주요 목표이다.
    - HTTP Clients 나 MySQL, PostgreSQL, Memcached, Redis 같은 remote backends 와 통신을 위한 Non blocking I/O 처리하기 위한 Nginx event model 을 이용한다.

* 실제로 OpenResty applications 들은 dynamic web portals, web gateways, web application firewalls, web service platforms for mibile app/advertising/distributed storage/data analytics 부터 full-fleged dynamic web applications, web sites 까지 구현가능하다.
* Hardware 에서는 아주 대형 기계에서 부터 아주 제한적인 리소스를 가진 임베디드 디바이스까지 OpenResty를 실행할 수 있다.
* OpenResty는 Nginx 에서 파생된게 아니라 Nginx 를 이용하는 Components  같이 high level application and gateway platform 이다.
    - 공식 Nginx core team, 공식 LuaJIT repository, 그외 sources 에서 버그수정과 최신 기능들을 가져와서 지속적으로 작업 하고 있다.

* 1.15.8.1 release 이전은 기본적으로 standard Lua 5.1 interpreter 가 enabled 되지만, 하지만 LuaJIT 2.x 는 그렇지 않다.
    - 2.x 를 사용하려면 옵션 --with-luajit 에 명시적으로 서술해 줘야한다(기본값은 1.5.8.1+ 이다)
* 1.15.8.1 release 이후는 기본으로 standard Lua 5.1 interpreter 더이상 제공되지 않는다.
    - https://github.com/openresty/luajit2 여기 소스를 사용한다.

* Components
    - https://openresty.org/en/components.html
* 3rd-party OpenResty modules
    - https://opm.openresty.org/

# [Installation](https://github.com/openresty/lua-nginx-module#installation)

* Nginx, ngx_lua (this module), LuaJIT, as well as other powerful companion Nginx modules and Lua libraries 들의 집합인 OpenResty 사용을 강력 추천한다.
* 이 모듈은 올바르게 setup 하는게 어렵기 때문에 Nginx 와 함께 빌드 하는건 추천하지 않는다. 
* 주의 : Nginx, LuaJIT, and OpenSSL official releases 들은 다양한 제한과 모듈기능들이 활성화 되지 않거나 오동작하는 등의 장기간 해결되지 않은 버그들을 갖고 있다. <br>`Official OpenResty releases 들 사용을 추천한다`, 이유는 OpenResty's optimized LuaJIT 2.1 fork and Nginx/OpenSSL patches 들의 통합하고 있기 때문이다. 

## 위 문제들의 대안으로 다음과 같이 ngx_lua 를 수동으로 Nginx 에 컴파일 할 수 있다 :
* [latest release of OpenResty's LuaJIT](https://github.com/openresty/luajit2/releases) 에서 LuaJIT 을 다운로드 한다
(위에서 언급한 사유로 인한 퍼포먼스 저하가 있을 지라도 official LuaJIT 2.x releases 또한 지원된다).
* [latest version of the ngx_devel_kit (NDK) module](https://github.com/simplresty/ngx_devel_kit/tags) 다운로드 한다.
* [latest version of ngx_lua](https://github.com/openresty/lua-nginx-module/tags)
* [latest supported version of Nginx](https://nginx.org/) 다운로드 한다. [호환성 표 참조](https://github.com/openresty/lua-nginx-module#nginx-compatibility)
* [latest version of the lua-resty-core](https://github.com/openresty/lua-resty-core) 다운로드 한다.
* [latest version of the lua-resty-lrucache](https://github.com/openresty/lua-resty-lrucache) 다운로드 한다.
### 위 모듈들과 함께 아래와 같이 컴파일 한다.
```sh
# Nginx 1.19.3 다운로드 후 풀기
wget 'https://openresty.org/download/nginx-1.19.3.tar.gz'
 tar -xzvf nginx-1.19.3.tar.gz
 cd nginx-1.19.3/

## LuaJIT 라이브러리 설정 둘중 하나 환경변수 설정
 # tell nginx's build system where to find LuaJIT 2.0:
 export LUAJIT_LIB=/path/to/luajit/lib
 export LUAJIT_INC=/path/to/luajit/include/luajit-2.0

 # tell nginx's build system where to find LuaJIT 2.1:
 export LUAJIT_LIB=/path/to/luajit/lib
 export LUAJIT_INC=/path/to/luajit/include/luajit-2.1

 # Here we assume Nginx is to be installed under /opt/nginx/.
 ./configure --prefix=/opt/nginx \
         --with-ld-opt="-Wl,-rpath,/path/to/luajit/lib" \
         --add-module=/path/to/ngx_devel_kit \
         --add-module=/path/to/lua-nginx-module

 # 아래와 같이 컴파일 머신의 spare CPU cores 개수에 맞게 2 숫자를 변경할 수 있다.
 make -j2
 make install
 
 # 주의 : 이 lua-nginx-module 버전은 더이상 `lua_load_resty_core off;` 만으로 설정하지 못한다.
 # 그러므로 아래와 같이 `lua-resty-core` and `lua-resty-lrucache` 모듈을 수동으로 nginx home 에 설치해줘야 한다.
 cd lua-resty-core
 make install PREFIX=/opt/nginx
 cd lua-resty-lrucache
 make install PREFIX=/opt/nginx

 # add necessary `lua_package_path` directive to `nginx.conf`, in the "http context"
 lua_package_path "/opt/nginx/lib/lua/?.lua;;";
```
## dynamic module 로 컴파일 하기
* 이 모듈은 NGINX 1.9.11 부터는 dynamic module 로 컴파일 할수 있다.
* .configure 명령어에 `--add-dynamic-module=PATH` option 에 .so 파일 추가
* 명시적으로 nginx.conf 파일에 load directive 에 다음과 같이 지정한다,
```
load_module /path/to/modules/ndk_http_module.so;  # assuming NDK is built as a dynamic module too
load_module /path/to/modules/ngx_http_lua_module.so;
```

## C Macro Configurations : 디버깅 옵션으로 사용
이 모듈을 OpenResty 나 Nginx core 와 함께 컴파일 하는동안 C compile 옵션에 다음과 같은 매크로 정의가 필요하다 :

* NGX_LUA_USE_ASSERT 정의되면 : ngx_lua C code base 에서 assertions 이 활성화 되어서 debugging or testing builds 등이 가능해진다. 물론 약간의 오버해드가 발생할 수 있다. 이 메크로는 v0.9.10 release 버전부터 지원된다.
* NGX_LUA_ABORT_AT_PANIC 정의되면 : LuaJIT VM panics 일때 ngx_lua 의 기본동작은 current nginx worker process 를 절차대로 종료되게 제어한다.
하지만 이 매크로가 정의되면 ngx_lua 는 current nginx worker process 는 즉시 종료시키고 core dump file 에 결과를 남긴다. 이 매크로는 VM panics 을 디버깅하는데 유용하다. 이 매크로는 v0.9.8 release 부터 지원된다.
```
./configure --with-cc-opt="-DNGX_LUA_USE_ASSERT -DNGX_LUA_ABORT_AT_PANIC"
```