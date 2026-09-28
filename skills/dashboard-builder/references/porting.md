# Levar para um frontend de projeto (React/Next, Vue, etc.)

Quando o painel precisa viver dentro de um app (ex.: o frontend do MAE) em vez de um Artifact avulso, reaproveite **os padrões e as regras**, não o HTML.

## Ordem de prioridade

1. **Design system do projeto primeiro.** Procure tokens, tema, componentes de cartão, tabela, drawer e gráfico já existentes (CLAUDE.md, `theme.ts`, `tokens.css`, Tailwind config). Use-os. As paletas desta skill só entram se o projeto não tiver identidade.
2. **Biblioteca de gráficos do projeto**, se houver (Recharts, ECharts, Nivo, Chart.js). Senão, SVG próprio como no motor (sem dependência).
3. **Regras desta skill sempre**: unidades, variação e direção (data-rules.md), hierarquia em 3 níveis, uma unidade por eixo, tudo clicável, animação de-para, estados vazios e sem base.

## Mapeamento motor → componentes

| Motor | Componente |
|---|---|
| `CONFIG.metrics` + `fmt`/`delta` | `lib/metrics.ts`: tipos `Metric {label, unit, dir, decimals}` e funções puras `format`, `delta`, `favorable` (teste unitário nelas) |
| `rows` + `derive` | Hook `useDashboardData(periodo)` buscando a API e aplicando `derive` |
| Cartões nível 1 e 2 | `<KpiTile metric value base spark onClick>` |
| Índices | `<RatioCard status>` |
| Tabela de variação | `<VarianceTable rows cmp>` com a formatação condicional como função pura |
| Ponte | `<Waterfall steps>` |
| Tendência + projeção + scrubber | `<TrendChart series horizon>` + `project()` em `lib/forecast.ts` |
| Quebra | `<BreakdownList dimension onSelect>` |
| Painel lateral | `<DetailDrawer metric>`, estado na URL (`?detail=receita`) para permitir compartilhar |
| Insights / resumo | `lib/insights.ts` (mesmas 6 regras) e renderização separada |
| Exportar | CSV no cliente (mesmo formato) e PDF no servidor (Playwright/Puppeteer) ou jsPDF no cliente |
| Parecer | Rota de API do projeto chamando a API da Anthropic (modelo atual; veja a skill `claude-api`), nunca a chave no cliente |

## Estado e filtros

- Período, base de comparação e detalhe aberto na URL (query string), para links compartilháveis e voltar/avançar funcionar.
- Animação de números com cancelamento no `useEffect` (cleanup cancela o `requestAnimationFrame`).
- `prefers-reduced-motion` desliga as animações.

## Verificação

- Testes unitários de `format`, `delta` (casos: base 0, sinal trocado, base pequena, p.p., pts) e `project`.
- Rode o app e faça o mesmo checklist do `check.mjs` na rota do painel (erros de console, fundo, celular 390px, cliques). O script aceita URL: `node scripts/check.mjs http://localhost:3000/painel`.
