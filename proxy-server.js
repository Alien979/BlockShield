const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

app.use('/api', createProxyMiddleware({ 
  target: 'http://localhost:7545',
  changeOrigin: true,
}));

app.listen(3000, () => {
  console.log('Proxy server running on port 3000');
});