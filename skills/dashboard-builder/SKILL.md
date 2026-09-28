---
name: dashboard-builder
description: >-
  Constrói dashboards e painéis interativos de nível analista sênior para qualquer domínio (finanças, operações, produto, vendas, marketing, RH, SaaS, projetos como o MAE) como página HTML única e publicável, com KPIs hierarquizados, comparação com período anterior, ano anterior e meta, análise de variação, drill-down, projeção, insights calculados, exportação CSV/PDF e animações. Use esta skill sempre que o usuário pedir um dashboard, painel, cockpit, relatório interativo, visão de KPIs, métricas, indicadores, analytics ou "tela para acompanhar" números, ou quando colar um prompt de dashboard, mesmo que não diga "dashboard" (ex.: "quero ver receita x despesa por mês", "monta uma visão do funil", "acompanhar SLA do suporte"). Também para auditar ou elevar um dashboard existente.
---

# Dashboard Builder

Esta skill transforma um pedido de painel em uma página HTML única, clara, animada e clicável, que roda como Artifact (ou arquivo) sem build. Ela nasceu de 10 dashboards financeiros refinados com o usuário; o que ele aprovou virou regra aqui. Os princípios valem para qualquer domínio.

## O que o usuário valoriza (não negociar sem pedido explícito)

- **Tema claro travado.** O app dele roda em tema escuro e páginas que seguem o sistema ficaram "escuras e sem graça". Defina tokens só em `:root`, sem blocos `prefers-color-scheme: dark`, e `background-color` explícito no `body`.
- **Identidade visual própria por painel.** Grade uniforme de cartões iguais foi rejeitada como "igual ao primeiro". Use hierarquia e layout bento, com um cartão herói em gradiente.
- **Animação que informa.** Números que transitam do valor antigo para o novo, linhas que se desenham, barras que crescem, revelação em sequência. Tudo dispara no carregamento; scroll só antecipa.
- **Tudo clicável.** Cartões e linhas abrem um painel lateral com histórico; legenda liga e desliga séries; linha do tempo com scrubber; filtros recalculam tudo; valores editáveis quando fizer sentido.
- **Profundidade de analista.** Números exatos e variações, nunca conselho genérico. Os favoritos dele foram o Cockpit do CFO Pro (`assets/templates/cfo-pro-analyst.html`) e o Patrimônio (`assets/templates/networth-editable.html`).

## Fluxo

### 1. Entender o pedido (rápido)

Extraia do pedido, sem interrogatório longo:
- **Domínio e público**: quem lê e que decisão toma com o painel.
- **Métricas** e, para cada uma, **unidade** (moeda, número, %, minutos, pontos) e **direção** (subir é bom ou ruim? custo, churn e tempo de resposta sobem mal).
- **Período** (mês, semana, trimestre) e se há **meta/orçado**.
- **Dimensão de quebra** (segmento, canal, região, produto, cliente).
- **Dados**: reais (CSV, planilha, API, banco) ou exemplo. Sem dados reais, gere dados de exemplo plausíveis e deterministas, marcados como exemplo, e isole-os no topo para troca fácil.

Pergunte só o que bloqueia de verdade. Placeholders do tipo `[TIPO DE NEGÓCIO]` podem ser preenchidos com uma escolha sensata e dita ao usuário.

### 2. Escolher o caminho

- **Caminho A: motor configurável (padrão).** Serve para a grande maioria: série temporal de métricas, com ou sem meta e quebra. Escreva só um objeto `CONFIG` e gere o painel com:
  ```bash
  python scripts/new_dashboard.py minha.config.js painel.html
  ```
  O contrato completo está em `references/engine-config.md`. Exemplos prontos: finanças no próprio motor (`assets/engine/dashboard-engine.html`), operações e suporte em `assets/examples/ops.config.js` (mensal, metas, minutos, NPS) e projeto por sprint em `assets/examples/project-sprints.config.js` (períodos rotulados, dias, métrica neutra, CPI/EAC).
- **Caminho B: padrão sob medida.** Quando a visualização central não é uma série temporal: fluxo de dinheiro (Sankey), orçado × realizado por item (bullet), simulador com sliders e cenários, patrimônio editável, varredura de anomalias. Parta do template mais próximo em `assets/templates/` (índice em `references/patterns.md`) e adapte, mantendo as regras desta skill.
- **Combinação**: gere pelo motor e acrescente uma seção sob medida copiando o padrão do template.

### 3. Desenhar

- **Hierarquia em 3 níveis**: (1) resultado, 2 a 3 números que respondem "estamos bem?"; (2) qualidade e custos; (3) índices e fôlego. O primeiro cartão do nível 1 é o herói em gradiente.
- **Paleta**: escolha uma das 6 aprovadas (`violeta`, `esmeralda`, `creme`, `cimento`, `menta`, `eletrico`) conforme o clima do domínio, ou crie uma nova seguindo `references/design-system.md`. Nunca repita a mesma paleta em painéis vizinhos do mesmo usuário sem motivo.
- **Uma unidade por eixo.** Nunca misture moeda com contagem no mesmo gráfico nem use eixo duplo. O gráfico "Caixa ÷10" no mesmo eixo da receita foi removido na auditoria por enganar a escala.
- **Semântica de cor**: verde favorável e vermelho desfavorável considerando a direção da métrica (custo que cai é verde). Cor de série não é cor de status.

### 4. Construir

- Página única: `<title>` e `<style>` no topo, sem `<html>`/`<head>`/`<body>` se for publicar como Artifact. Scripts externos só de cdnjs (jsPDF: `https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js`).
- Valores guardados na **unidade natural** (reais em reais, porcentagem como fração 0 a 1). Formate só na exibição. Veja `references/data-rules.md`.
- Exportar e "parecer com Claude" usam capacidades do Artifact (`downloads`, `sample`); os botões ficam ocultos quando a capacidade não existe. Veja `references/capabilities.md`.
- Feche o `</script>`. Parece óbvio, mas já deixou um painel inteiro em branco.

### 5. Verificar antes de entregar (sempre)

```bash
node scripts/check.mjs painel.html --click ".tile[data-metric=receita]" --click ".segrow" --click "#f-cmp button[data-c=bud]"
```
(Seletores do motor em `references/engine-config.md`; em templates, use os `id`/classes do próprio arquivo.) O script checa erros de JS, se o script rodou, fundo claro com host em tema escuro, elementos presos invisíveis, rolagem horizontal a 390px e cliques. Depois **olhe uma vez** os prints gerados (desktop e celular), procurando `NaN`, `—` onde deveria haver número, rótulos sobrepostos, valores com ordem de grandeza errada ("R$ 182M" em vez de "R$ 182k") e barras vazias. Corrija e publique. Cada item do checklist veio de um bug real (`references/pitfalls.md`).

Em ambientes sem Playwright: `npm i playwright` (ou aponte `PW_CHROMIUM` para um Chromium já instalado).

### 6. Entregar

- **Artifact**: publique o `.html`; ao usar exportação ou parecer, declare `capabilities: {"downloads": true, "sample": {}}`.
- **Projeto com frontend próprio** (React/Next, como o MAE): siga `references/porting.md`, reaproveitando o design system do projeto e mantendo os padrões de interação e as regras de dados.
- Resuma ao usuário em poucas linhas o que o painel faz, o que foi testado e o que não pôde ser testado (ex.: confirmação de download real).
- Ao auditar ou elevar um painel existente, inclua **5 perguntas que o painel responde, 3 lacunas nos dados e 3 melhorias** (o motor tem a seção `audit` para isso).

## Referências

| Arquivo | Quando ler |
|---|---|
| `references/engine-config.md` | Caminho A: contrato completo do `CONFIG` |
| `references/patterns.md` | Caminho B: catálogo de padrões e templates, qual usar para quê |
| `references/design-system.md` | Paletas aprovadas, tokens, layout, tipografia, como criar paleta nova |
| `references/data-rules.md` | Unidades, formatação, variação, comparação, projeção, regras dos insights |
| `references/capabilities.md` | Exportar CSV/PDF e parecer com Claude dentro do Artifact |
| `references/pitfalls.md` | Bugs que já aconteceram e como evitar |
| `references/prompts.md` | Os 10 prompts originais mapeados e modelos de prompt para outros domínios |
| `references/porting.md` | Levar os padrões para React/Next ou outro frontend |
