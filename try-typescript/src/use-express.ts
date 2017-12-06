import express = require("express");

const app = express();

app.get("/echo/:text", (req, res) => {
  res.send(req.params.text);
});

app.listen(3000, () => {
  console.log("listening on 3000");
});