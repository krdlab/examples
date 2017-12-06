import * as client from "scoped-http-client";

client.create("https://httpbin.org/get")
  .query({"word": "typescript", "count": 10})
  .get()((err, res, body) => {
    console.log(body);
  });