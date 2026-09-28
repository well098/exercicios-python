# Design system

## Tema claro travado

O usuário usa o app em tema escuro, e páginas que seguiam o sistema pareceram "escuras". A regra:
- Todos os tokens em `:root`, com `color-scheme: light`.
- **Nenhum** bloco `@media (prefers-color-scheme: dark)` nem `:root[data-theme="dark"]`.
- `body { background-color: var(--bg); }` explícito (o viewer pinta o próprio fundo atrás de um body transparente).
- Texto escuro sobre superfícies claras; texto branco só dentro de cartões em gradiente.

`scripts/check.mjs` abre a página com o host em tema escuro e reprova fundo com luminância < 0,6.

## Paletas aprovadas (usadas no motor via `palette`)

| Nome | Clima | bg | accent | séries c1 a c5 | Origem |
|---|---|---|---|---|---|
| `violeta` | executivo vibrante | `#f3f1fb` | `#6a4bff` | `#6a4bff #12b5dc #ff7a1a #ff4d9d #23c552` | Cockpit do CFO (favorito) |
| `esmeralda` | patrimônio, riqueza | `#eef5f1` | `#0f8a5f` | `#0f8a5f #22407a #c9971a #2f9bd6 #8a5cc7` | Patrimônio (favorito) |
| `creme` | quente, bege/white | `#f5efe4` | `#6a4bff` | `#6a4bff #ff7a1a #12a150 #ff4d7d #0bb4d4` | Runway |
| `cimento` | industrial, cimento queimado | `#d7d3ca` | `#b1552e` | `#476174 #b1552e #5f7a58 #b58a2e #9c5642` | Insights IA |
| `menta` | fintech limpo | `#eaf3f1` | `#0e9f8f` | `#0e9f8f #7c6ff0 #f2683c #e4a70a #4a9bd6` | Fluxo de caixa |
| `eletrico` | alto contraste claro | `#f4f6fe` | `#4f6bff` | `#4f6bff #8b5cff #22b8ff #ff5d73 #ffab2e` | Orçado × Realizado |

Os valores completos (surface, ink, hair, gradientes, glows) estão em `PALETTES` no motor.

**Semântica fixa em todas as paletas:** bom `#12a150`, ruim `#e5194b`, atenção `#c98200`/`#f0a500`. Nunca use essas cores como cor de série.

### Criar uma paleta nova

Passe um objeto em `CONFIG.palette` com as mesmas chaves (`bg`, `surface`, `surface-2`, `ink`, `ink-2`, `muted`, `hair`, `hair-2`, `accent`, `c1` a `c5`, `grad-hero`, `grad-alt`, `glow-1`, `glow-2`). Regras:
- Neutros com leve tom da cor de destaque (cinza puro parece sem cuidado).
- `ink` com contraste ≥ 7:1 sobre `surface`; `ink-2` ≥ 4,5:1.
- Séries em ordem fixa, nunca recicladas; no máximo 5; acima disso agrupe em "Outros".
- Evite os clichês de IA: creme + serifa + terracota, preto + um neon, gradiente roxo-azul em hero branco. (O "creme" aprovado usa sans e acentos vibrantes, não terracota.)

## Layout

- **Hierarquia em níveis** com rótulos numerados ("1 · Resultado"): a numeração aqui é informação (ordem de leitura), não enfeite.
- **Nível 1**: grade `1.35fr 1fr 1fr`; o herói (1º) em `--grad-hero`, um secundário opcional em `--grad-alt`.
- **Nível 2**: 4 colunas compactas com sparkline. **Nível 3**: cartões de índice com borda esquerda de status.
- **Cartões** 20px de raio, sombra suave em duas camadas; bordas e sombras dão hierarquia, então não aplique a mesma coisa em tudo.
- **Filtros** numa barra fixa (`position: sticky; top: env(safe-area-inset-top)`).
- **Celular**: tudo em 1 coluna abaixo de 900/440px; tabelas e gráficos largos dentro de `overflow-x: auto`; margem lateral ≥ 16px; nada com largura mínima maior que a tela.

## Tipografia e números

- Fonte do sistema (`system-ui`) em tudo; `font-variant-numeric: tabular-nums` para colunas.
- Valor herói de 44px, nível 1 de 30px, nível 2 de 24px, rótulos de 11 a 12px em caixa alta com espaçamento.
- Números sempre formatados (`R$ 716,6k`, `69,1%`, `22 min`, `+8,0 pts`), nunca crus.

## Gráficos

- Uma unidade por eixo; sem eixo duplo.
- Grade discreta, linhas de 2 a 3px com pontas arredondadas, ponto de destaque no período selecionado.
- Legenda sempre que houver 2 séries ou mais; clicável para ocultar.
- Tooltip em todo ponto ou barra; faixa de clique maior que a marca.
- `viewBox` proporcional ao espaço real (largura total ≈ 1180, metade ≈ 560). Um viewBox pequeno esticado deixa o texto gigante.
