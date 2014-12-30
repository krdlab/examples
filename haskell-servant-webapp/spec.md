POST /memos
-----------

**Request Body**: 

``` javascript
{"memo":"Try haskell-servant."}
```

**Response**: 

 - Status code 201
 - Response body as below.

``` javascript
{"createdAt":"2014-12-31T12:00:00.000+0900","text":"Try haskell-servant.","id":5}
```

DELETE /memos/:id
-----------------

**Captures**: 

- *id*: memo id

**Response**: 

 - Status code 204
 - No response body

GET /memos
----------

**Response**: 

 - Status code 200
 - Response body as below.

``` javascript
[{"createdAt":"2014-12-31T12:00:00.000+0900","text":"Try haskell-servant.","id":5}]
```


