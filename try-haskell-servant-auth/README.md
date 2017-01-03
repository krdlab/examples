http://haskell-servant.readthedocs.io/en/stable/tutorial/Authentication.html

```sh
$ stack setup
$ stack build
$ stack exec try-haskell-servant-auth

$ curl localhost:3000/
"unprotected url"

$ curl localhost:3000/account
Missing token header

$ curl localhost:3000/account -H 'X-Servant-Auth-Token: key1'
{"name":"Account1"}

$ curl localhost:3000/account -H 'X-Servant-Auth-Token: key4'
Invalid token
```
