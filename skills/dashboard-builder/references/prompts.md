# Biblioteca de prompts

## Os 10 prompts originais (finanças) e o caminho recomendado

| # | Prompt (resumo) | Caminho | Base |
|---|---|---|---|
| 1 | Painel completo de finanças: receita, despesas, lucro, fluxo, orçado × real, saldo, KPIs, tendências, divisão de despesas, transações, filtros | Motor | Config com `table` de receita/despesa por categoria + `breakdown` por categoria |
| 2 | CSV para dashboard `[DATA, DESCRIÇÃO, CATEGORIA, RECEITA, DESPESA, CONTA, SALDO]` | Motor + conversão | Script que agrega o CSV por mês em `rows`; `breakdown` por categoria ou conta |
| 3 | DRE mensal com orçado, mês anterior e 12 meses | Motor | O config de exemplo do motor já é um DRE; `dre-waterfall.html` para a versão clássica |
| 4 | Fluxo de caixa com projeção de 3 meses e alerta de caixa mínimo | Sob medida | `cashflow-sankey.html` |
| 5 | Orçado × realizado por categoria com semáforo e projeção de fechamento | Sob medida | `budget-bullets-scroll.html` |
| 6 | Dashboard do CFO de uma página com resumo em 3 pontos | Motor | Config padrão do motor (é o CFO Pro) |
| 7 | Runway de startup com cenários | Sob medida | `runway-scenarios.html` |
| 8 | Insights financeiros com IA, anomalias com números exatos | Motor (insights) ou sob medida | `anomaly-insights.html` |
| 9 | Patrimônio líquido pessoal | Sob medida | `networth-editable.html` |
| 10 | Elevar um dashboard ao nível analista + 5 perguntas / 3 lacunas / 3 melhorias | Auditoria | Compare com o motor; preencha `audit`; exemplo: `cfo-pro-analyst.html` |

## Modelo de prompt para qualquer domínio

> Crie um painel de **[DOMÍNIO]** para **[PÚBLICO]** decidir **[DECISÃO]**. Período **[mensal/semanal]**, últimos **[N]** períodos, com **[meta/orçado/sem meta]**. Métricas: **[métrica (unidade, sobe bom ou ruim)]**, … Quebra por **[dimensão]**. Destaque **[o que precisa saltar aos olhos]**. Dados: **[CSV/planilha/exemplo]**. Paleta: **[nome ou clima]**.

Com esse texto, a skill preenche um `CONFIG` diretamente. Se faltar "sobe bom ou ruim", infira pelo nome (custo, tempo, erro, churn = sobe ruim) e diga a escolha.

## Exemplos prontos para adaptar

**Operações e suporte** (pronto em `assets/examples/ops.config.js`)
> Painel da operação da plataforma: usuários ativos, cadastros, tickets, tickets por mil usuários, tempo de resposta (min), SLA, NPS, uptime, custo de infra e de suporte. Metas para SLA, tempo, NPS e uptime. Quebra por canal (chat, e-mail, telefone).

**Vendas / funil**
> Painel comercial mensal: leads, oportunidades, taxa de conversão (%), ticket médio, receita nova (MRR), ciclo de venda (`days`), churn (%, sobe ruim). Meta por mês. Quebra por vendedor ou canal de aquisição. Ponte do MRR: novo + expansão − churn − contração.

**Produto / SaaS**
> Painel de produto semanal (`periodType: "label"`, `yearLag: 52`): DAU, WAU, retenção D30 (%), ativação (%), tempo até valor (min), erros por mil sessões (sobe ruim). Quebra por plano.

**Projeto / governança (ex.: MAE)** (molde pronto em `assets/examples/project-sprints.config.js`, com números inventados)
> Painel de acompanhamento do **[projeto]**: entregas concluídas × planejadas, % do escopo, lead time (dias), bugs abertos (sobe ruim), custo acumulado × orçado, horas por frente. Quebra por frente/equipe. Metas por sprint (`periodType: "label"`). Resumo executivo com o que avançou, o que atrasou e o risco principal.

**Sistema de inteligência (MAE) · painel de comando**
> O cliente entra e vê o que o sistema percebeu na empresa, com evidências, impacto e o que fazer; recomendações com aprovar/rejeitar; ações, resultados e aprendizado; perfis de cliente, fornecedor e produto com "o que foi percebido"; perguntas respondidas com fontes; cobertura das fontes de dados. → Caminho C, template `signal-command-center.html`.

Para um painel **dentro** do frontend do projeto (não como Artifact), veja `porting.md`.
