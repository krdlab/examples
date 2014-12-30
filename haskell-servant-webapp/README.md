# haskell-servant example

[haskell-servant](http://haskell-servant.github.io/)

## Run

```sh
$ cabal sandbox init
$ cabal install --only-dependencies
$ cabal build
$ ./dist/build/example-server/example-server s      # s: run server, d: generate document (to stdout)
```

## Check

```sh
$ curl -v \
    -X POST \
    -d '{"memo":"Try haskell-servant."}' \
    http://localhost:8000/memos

$ curl -v \
    http://localhost:8000/memos

$ curl -v \
    -X DELETE \
    http://localhost:8000/memos/1
```

