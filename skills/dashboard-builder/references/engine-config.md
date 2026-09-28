# Contrato do CONFIG (motor configurável)

O motor (`assets/engine/dashboard-engine.html`) lê um único objeto `CONFIG` e monta tudo: 3 níveis de KPIs, índices, tabela de variação com formatação condicional, ponte (waterfall), tendência com projeção e scrubber, quebra por dimensão com drill-down, insights calculados, resumo executivo, auditoria, exportação CSV/PDF e parecer com Claude.

Gere um painel novo com `python scripts/new_dashboard.py minha.config.js saida.html`. O arquivo precisa declarar `const CONFIG = ...;`. Um IIFE (`const CONFIG = (() => { ...; return {...}; })();`) é o jeito mais limpo de gerar dados de exemplo ou transformar dados reais antes de devolver o objeto.

## Campos

| Campo | Obrigatório | Tipo | Para quê |
|---|---|---|---|
| `title` | sim | string | Nome do painel (vira o `<title>` e o nome na galeria). Nome curto, específico. |
| `eyebrow`, `subtitle`, `footnote` | não | string | Linha acima do título, instrução de uso, nota de rodapé (ex.: "Dados de exemplo…"). |
| `palette` | não | string ou objeto | `violeta`, `esmeralda`, `creme`, `cimento`, `menta`, `eletrico`, ou um objeto de tokens (ver design-system.md). Padrão: violeta. |
| `currency` | não | `"BRL"`, `"USD"`, `"EUR"` | Prefixo das métricas `currency`. |
| `periodType` | não | `"month"` ou `"label"` | `month` espera `p` no formato `AAAA-MM` e mostra "Set/26"; `label` mostra `p` como está (semanas, sprints, trimestres). |
| `yearLag` | não | número | Períodos por ano para a comparação "ano anterior" (12 meses, 52 semanas, 4 trimestres). O botão some se não houver histórico suficiente. |
| `budgetLabel` | não | string | Como chamar a referência: "Orçado", "Meta", "Plano", "Forecast". O botão some se não houver `b` em nenhuma linha. |
| `metrics` | sim | objeto | Dicionário de métricas (abaixo). |
| `derive` | não | função `(x) => x` | Calcula métricas derivadas. Roda em cada `v`, em cada `b` e em cada membro da dimensão. Proteja contra campos ausentes. |
| `rows` | sim | array | Uma linha por período, em ordem cronológica (abaixo). |
| `tiers` | sim | objeto | `labels` (3 textos), `t1` (1 a 3 métricas; o 1º vira o herói), `t2` (até 4). Itens podem ser `"chave"` ou `{key, title, style}`, com `style` em `hero`, `alt` (gradiente secundário) ou `plain`. |
| `tileFoot` | não | `(key, c) => html` | Linha extra dentro de um cartão (ex.: "margem 10% · orçado R$ 69k"). |
| `ratios` | não | `(c) => [{label, value, note, status}]` | Nível 3. `status` em `good`, `warn` ou `bad`. Omitir esconde o nível. |
| `table` | sim | array | Linhas da tabela de variação: `"chave"` ou `{key, style}`, com `style` em `total` ou `sub`. |
| `bridge` | não | objeto | `{title, target, parts:[{key, sign, label}]}`. Explica a variação de `target` pela soma dos efeitos; `sign` é +1 se a parte soma no alvo e −1 se subtrai. A diferença não explicada vira "Outros". Omitir esconde a ponte. |
| `trend` | sim | objeto | `{title, series:[chaves], horizon}`. **Use séries da mesma unidade.** `horizon` = períodos projetados (0 desliga). A 1ª série é o "indicador principal" dos insights. |
| `breakdown` | não | objeto | `{title, dimension, metric, secondary, secondaryLabel, members:[{k, color}]}`. `color` é um token (`--c1` a `--c5`). |
| `attention` | não | `(c) => {t, b} \| null` | Regra do cartão "Exige atenção" do resumo. Sem ela, o motor usa a maior anomalia. |
| `insights` | não | `(c) => [{cls, t, h}]` | Insights extras do domínio (`h` aceita `<b>`). Somam-se aos 6 automáticos. |
| `summaryKeys` | não | array | Métricas avaliadas em "melhorou/piorou". Padrão: níveis 1 e 2. |
| `drillNote` | não | `(key, c) => html` | Texto extra no painel lateral de uma métrica. |
| `audit` | não | objeto | `{questions, gaps, improvements, changes}` (listas de strings). Mostra a seção "Auditoria". |
| `aiContext` | não | string | Complemento do prompt do parecer: "…responsável por **{aiContext}**". |

### `metrics`

```js
metrics: {
  receita:  { label: "Receita", unit: "currency", dir: 1 },
  churn:    { label: "Churn", unit: "percent", dir: -1, decimals: 2 },
  nps:      { label: "NPS", unit: "score", dir: 1 },
  resposta: { label: "Tempo de resposta", unit: "minutes", dir: -1 },
  caixa:    { label: "Caixa", unit: "currency", dir: 1, noBudget: true },
}
```
- `unit`: `currency`, `number`, `percent` (fração 0 a 1), `minutes`, `score`.
- `dir`: `1` se subir é bom, `-1` se subir é ruim. Define cor, "melhorou/piorou" e a ponte.
- `decimals`: casas para `percent` e `score` (uptime 99,95% pede 2).
- `noBudget`: a métrica não tem meta (esconde a comparação com a meta nela).
- `absDelta`: força a variação em valor absoluto em vez de %. `score` já é absoluto ("+8,0 pts").

### `rows`

```js
{ p: "2026-09",                  // período
  v:   { receita: 716582, ... },  // realizado
  b:   { receita: 700722, ... },  // meta/orçado (opcional)
  dim: { "SaaS": { receita: 485300, cmv: 87000 }, ... },   // quebra (opcional)
  bdim:{ "SaaS": { receita: 470000 }, ... } }             // meta da quebra (opcional)
```
Métricas que dependem de períodos anteriores (média móvel, runway, acumulado) devem ser calculadas no IIFE antes de devolver `rows`, porque `derive` enxerga uma linha por vez.

### Objeto `c` recebido pelas funções

`c.i` (índice), `c.row`, `c.rows`, `c.prevRow`, `c.yoyRow` (ou `null`), `c.base(key)` (valor da base de comparação escolhida), `c.cmp` e `c.cmpLabel`, e os formatadores `c.fmt(unit, v, full, decimals)`, `c.num(v, casas)`, `c.signed(v, casas)` e `c.label(j)`.

## Dados reais

- **CSV/planilha**: converta para `rows` num script (Python/Node) e grave o `CONFIG` no arquivo de config, ou embuta os dados no IIFE. Mantenha a lógica de derivação em `derive`, não nos dados.
- **API/banco em produção**: o motor é para páginas autocontidas. Para dados vivos, use a capacidade `mcp` do Artifact (conectores) ou porte para o frontend do projeto (porting.md).
- Sempre diga ao usuário se os números são de exemplo.

## Checklist de config

- [ ] Toda métrica usada em `tiers`, `table`, `trend`, `bridge` e `breakdown` existe em `metrics`.
- [ ] `dir` correto em todas as métricas de custo, tempo e erro.
- [ ] `trend.series` na mesma unidade.
- [ ] Percentuais como fração (0,958, não 95,8).
- [ ] `node scripts/check.mjs` passou e os prints foram olhados.
