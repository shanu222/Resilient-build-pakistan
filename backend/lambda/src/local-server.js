import http from 'http';
import { handler } from './index.js';

const port = process.env.PORT || 3000;

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${port}`);
  const event = {
    rawPath: url.pathname,
    requestContext: { http: { method: req.method } },
    pathParameters: url.pathname.match(/^\/models\/([^/]+)/)
      ? { id: url.pathname.split('/')[2] }
      : undefined,
  };
  const result = await handler(event);
  res.writeHead(result.statusCode, result.headers ?? {});
  res.end(result.body);
});

server.listen(port, () => {
  console.log(`RBP API listening on http://localhost:${port}`);
});
