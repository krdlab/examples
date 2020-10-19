'use strict';
const express = require('express');
const session = require('express-session');

const app = express();
app.set('trust proxy', 1);
app.use(
  session({
    name: 'JSESSIONID',
    secret: 'ef0eoZ7rof',
    cookie: {
      httpOnly: true,
      maxAge: 3600 * 1000,
      secure: true,
    },
    saveUninitialized: false,
    resave: true,
  })
);

app.get('/', (req, res, _next) => {
  req.session.views = (req.session.views || 0) + 1;
  res.send(`${req.session.views} views`);
});

app.get('/status', (req, res, _next) => {
  res.send('OK');
});

app.listen(3000, () => console.log('listening 3000'));
