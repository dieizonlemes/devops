# DevOps do Zero ao Deploy — meu projeto

Este repositório é o **seu projeto do curso**. A cada módulo você escreve uma parte dele, faz commit e, no fim, tem uma aplicação que sai do seu código, passa por um pipeline, é publicada num cluster Kubernetes e é monitorada — tudo feito por você.

Ao terminar, ele vira o seu **portfólio**: mostre-o em entrevistas.

## Antes de começar (pré-requisito do curso)

1. Instale o **Git** (que traz o Git Bash) e o **VS Code**.
2. Crie este repositório a partir do template: botão **Use this template → Create a new repository**, marcando **Private**.
3. Clone no seu computador e abra no VS Code:
   ```bash
   git clone https://github.com/<seu-usuario>/<seu-repositorio>.git
   cd <seu-repositorio>
   code .
   ```
4. No terminal do VS Code (Git Bash), instale e confira as ferramentas:
   ```bash
   bash setup/instalar-ferramentas.sh
   bash setup/verificar-ambiente.sh
   ```

> **Por que privado?** No Módulo 3 você vai ligar um *runner* do GitHub no seu computador. Num repositório público, qualquer pessoa poderia abrir um pull request que executa código na sua máquina. No fim do curso você remove o runner e, se quiser, torna o repositório público.

## O que você constrói em cada módulo

| Módulo | Missão | Arquivos |
|---|---|---|
| 0 — Linux | Navegar, criar e editar arquivos pelo terminal, dentro deste repositório | — |
| 1 — Git | Commits, branches e pull requests no seu próprio projeto | — |
| 2 — Infraestrutura como Código | Criar o cluster Kubernetes local com Terraform | `infra/` |
| 3 — GitHub Actions | Pipeline de CI e o runner self-hosted no seu computador | `.github/workflows/pipeline.yml` |
| 4 — Build da aplicação | Empacotar a `minha-app` numa imagem Docker | `app/Dockerfile` |
| 5 — Deploy no cluster | Manifests do Kubernetes, deploy automático em homologação e promoção para produção | `k8s/`, `.github/workflows/` |
| 6 — Monitoramento | Prometheus, Grafana, alerta de taxa de erro — e o projeto final: detectar uma versão com defeito e fazer rollback | `infra/monitoramento.tf`, `monitoramento/` |

Os arquivos marcados com `TODO` são os que você escreve. As instruções detalhadas de cada missão estão nas lições do curso.

## Estrutura

```
app/            a aplicação (minha-app) e seus testes
infra/          Terraform: cluster kind, namespaces e monitoramento
k8s/            manifests do Kubernetes
monitoramento/  ServiceMonitor, alertas e gerador de carga
setup/          scripts de instalação e verificação do ambiente
.github/        workflows do GitHub Actions
```

## Comandos do dia a dia

```bash
cd infra && terraform apply          # sobe o cluster (e o que mais estiver no Terraform)
kubectl get pods -n hml              # a aplicação em homologação
kubectl get pods -n prod             # a aplicação em produção
cd infra && terraform destroy        # apaga o cluster ao terminar o dia
```

## Problemas comuns

| Sintoma | Solução |
|---|---|
| `bash\r: No such file or directory` | Arquivo com quebra de linha do Windows: `sed -i 's/\r$//' arquivo.sh` |
| `O Docker não está respondendo` | Abra o Docker Desktop e espere ele ficar pronto |
| Comando não encontrado logo após instalar | Feche e abra o terminal (o Windows atualiza o PATH só em terminais novos) |
| Job do GitHub Actions parado em "Waiting for a runner" | O runner no seu computador não está rodando: abra-o de novo (Módulo 3) |
| Job parado em "Queued" mesmo com o runner aparecendo como online | O runner travou depois de uma queda de conexão: na janela dele, `Ctrl+C` e rode `run.cmd` (ou `./run.sh`) de novo |
| `kubectl` falando com outro cluster | `kubectl config use-context kind-devops-lab` |
