# [nginx_cookie_flag_module](https://github.com/AirisX/nginx_cookie_flag_module.git)
이 Nginx 모듈은 "Set-Cookie" upstream response headers 해더에 쿠키용 "HttpOnly", "secure" and "SameSite" flag들을 설정하도록 한다.
이들 flags 에 등록된 문자열들이 제대로된 값으로 변경되는지에 대한 것은 검사하지 않는다. 또한 선언되는 몇가지 directive들 사이에 선언되는 순서도 상관하지 않는다.
기본값들로 설정되게 하려면 심볼 "*"을 사용하면 된다, 이경우 다른 값으로 덮어 쓰지 않는한 모든 쿠키값들이 추가될것이다.

# 호환성
1.11.x (last tested: 1.11.2)

# 설치
1. git clone git://github.com:AirisX/nginx_cookie_flag_module.git
2. Add the module to the build configuration by adding 
```
    --add-module=/path/to/nginx_cookie_flag_module
     or 
    --add-dynamic-module=/path/to/nginx_cookie_flag_module
```
3. make and install
```
make
make install
```

# 사용방법
```
location / {
    set_cookie_flag Secret HttpOnly secure SameSite;
    set_cookie_flag * HttpOnly;
    set_cookie_flag SessionID SameSite=Lax secure;
    set_cookie_flag SiteToken SameSite=Strict;
}
```
## set_cookie_flag directive in server or location
```
set_cookie_flag <cookie_name|*> [HttpOnly] [secure] [SameSite|SameSite=[Lax|Strict]];
```