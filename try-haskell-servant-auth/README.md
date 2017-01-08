# Try authentication in Servant

http://haskell-servant.readthedocs.io/en/stable/tutorial/Authentication.html

```sh
$ stack setup
$ stack build
$ stack exec try-haskell-servant-auth

$ curl localhost:3000/public
"public resource"

$ curl localhost:3000/account
Missing token header

$ curl localhost:3000/account -H 'X-Servant-Auth-Token: token1'
{"name":"account1"}

$ curl localhost:3000/account -H 'X-Servant-Auth-Token: unknown-token'
Invalid token
```
