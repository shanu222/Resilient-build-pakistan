/**
 * GET /models — list resilient housing models
 * GET /models/{id} — single model
 */

const SAMPLE = {
  models: [
    { modelId: 'interlocking_brick_masonry', name: 'Interlocking Brick Masonry' },
    { modelId: 'earthbag_masonry', name: 'Earthbag Masonry' },
  ],
};

export async function listModels() {
  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    body: JSON.stringify(SAMPLE),
  };
}

export async function getModel(event) {
  const id = event.pathParameters?.id;
  const model = SAMPLE.models.find((m) => m.modelId === id);
  if (!model) {
    return { statusCode: 404, body: JSON.stringify({ error: 'Not found' }) };
  }
  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    body: JSON.stringify(model),
  };
}
