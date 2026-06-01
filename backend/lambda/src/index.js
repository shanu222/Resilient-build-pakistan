import { getModel, listModels } from './handlers/models.js';

export async function handler(event) {
  const method = event.requestContext?.http?.method ?? event.httpMethod;
  const path = event.rawPath ?? event.path ?? '/';

  if (method === 'GET' && path === '/models') return listModels();
  if (method === 'GET' && path.startsWith('/models/')) return getModel(event);

  return {
    statusCode: 404,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ error: 'Not found', path }),
  };
}
