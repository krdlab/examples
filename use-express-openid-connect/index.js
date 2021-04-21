'use strict';

require('dotenv').config();
const express = require('express');
const { auth } = require('express-openid-connect');

const app = express();

app.use(auth({
  authorizationParams: {
    response_type: 'code',
    audience: 'http://localhost:3000/',
    scope: 'openid profile email offline_access direct.domains.readonly',
    prompt: 'consent',
    nonceSize: 30,
  },
}));

app.get('/', async (req, res) => {
  if (req.oidc.accessToken.isExpired()) {
    await req.oidc.accessToken.refresh();
  }
  console.log(req.oidc.accessToken);
  console.log(req.oidc.idToken);
  console.log(req.oidc.user);
  res.send(req.oidc.user);
});

// NOTE: 認証に成功すると appSession という Cookie が作成される．これがセッションの維持に使われる

app.listen(3000, () => {
  console.log('start server (port: 3000)');
});
