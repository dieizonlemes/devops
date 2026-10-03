// minha-app — a aplicação de exemplo do curso "DevOps do Zero ao Deploy".
// Servidor HTTP sem dependências externas, com as rotas que o curso usa:
//   GET /         → informações da aplicação (versão, Pod que respondeu)
//   GET /health   → usado pelas probes do Kubernetes
//   GET /metrics  → métricas no formato do Prometheus (Módulo 6)
const http = require('node:http');
const os = require('node:os');

const PORTA = Number(process.env.PORT || 3000);
const VERSAO = process.env.VERSAO || 'dev';
// Fração de requisições que falham de propósito (0 a 1). Usada no projeto
// final para simular uma versão com defeito e disparar o alerta.
const TAXA_ERRO = Number(process.env.TAXA_ERRO || 0);

const contadores = new Map(); // "rota|status" → total

function registrar(rota, status) {
  const chave = `${rota}|${status}`;
  contadores.set(chave, (contadores.get(chave) || 0) + 1);
}

function metricas() {
  const linhas = [
    '# HELP http_requests_total Total de requisições HTTP atendidas.',
    '# TYPE http_requests_total counter',
  ];
  for (const [chave, total] of contadores) {
    const [rota, status] = chave.split('|');
    linhas.push(`http_requests_total{rota="${rota}",status="${status}"} ${total}`);
  }
  linhas.push(
    '# HELP app_info Versão da aplicação em execução.',
    '# TYPE app_info gauge',
    `app_info{versao="${VERSAO}"} 1`,
  );
  return linhas.join('\n') + '\n';
}

function responder(res, rota, status, corpo, tipo = 'application/json') {
  registrar(rota, status);
  res.writeHead(status, { 'Content-Type': tipo });
  res.end(typeof corpo === 'string' ? corpo : JSON.stringify(corpo));
}

function criarServidor() {
  return http.createServer((req, res) => {
    const rota = new URL(req.url, 'http://localhost').pathname;

    if (rota === '/health') return responder(res, rota, 200, { status: 'ok' });
    if (rota === '/metrics') return responder(res, rota, 200, metricas(), 'text/plain; version=0.0.4');

    if (rota === '/') {
      if (Math.random() < TAXA_ERRO) {
        return responder(res, rota, 500, { erro: 'falha simulada' });
      }
      return responder(res, rota, 200, {
        app: 'minha-app',
        versao: VERSAO,
        pod: os.hostname(),
      });
    }

    return responder(res, 'outras', 404, { erro: 'rota não encontrada' });
  });
}

module.exports = { criarServidor };

if (require.main === module) {
  const servidor = criarServidor();
  servidor.listen(PORTA, () => console.log(`minha-app ${VERSAO} ouvindo na porta ${PORTA}`));
  // Encerramento limpo: o Kubernetes envia SIGTERM antes de remover o Pod.
  process.on('SIGTERM', () => servidor.close(() => process.exit(0)));
}
