// Testes da minha-app, executados pelo CI (Módulo 3) com: npm test
const { test, before, after } = require('node:test');
const assert = require('node:assert');
const { criarServidor } = require('./server');

let servidor;
let base;

before(async () => {
  servidor = criarServidor();
  await new Promise((resolve) => servidor.listen(0, resolve));
  base = `http://localhost:${servidor.address().port}`;
});

after(() => servidor.close());

test('GET / responde com o nome da aplicação', async () => {
  const resposta = await fetch(`${base}/`);
  assert.strictEqual(resposta.status, 200);
  const corpo = await resposta.json();
  assert.strictEqual(corpo.app, 'minha-app');
});

test('GET /health responde ok', async () => {
  const resposta = await fetch(`${base}/health`);
  assert.strictEqual(resposta.status, 200);
});

test('GET /metrics expõe o contador de requisições', async () => {
  const texto = await (await fetch(`${base}/metrics`)).text();
  assert.match(texto, /http_requests_total\{rota="\/",status="200"\} \d+/);
});
