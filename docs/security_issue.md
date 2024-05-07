# gitlabs
## graphql
1. __schema keyword 포함시 차단

## 세션값이 없이도 graphql 동작
* schema 요청시 session id 없이도 동작함, 다른 조회에서도 그런지 테스트
* gitlab에서 Public 권한 제한:
    - Admin > general > Visibility and access controls > Restricted visibility levels 체크
* cookie 나 http header 에 session id 가 있는지 nginx 에서 검사
    location / {
        proxy_pass http://backend;
        proxy_set_header Cookie $http_cookie;  <--쿠기값 저장해서 session id 로 세션데이터 저장>
    }
# 쿠키 보안설정
* 쿠키값이 노출되는 문제를 해결하기 위해서 cookie_flag module 사용으로 
```
location / {
    set_cookie_flag Secret HttpOnly secure SameSite;
    set_cookie_flag * HttpOnly;
    set_cookie_flag SessionID SameSite=Lax secure;
    set_cookie_flag SiteToken SameSite=Strict;
}
```


