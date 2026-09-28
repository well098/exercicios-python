# Regras de dados

## Unidades

- Guarde cada valor na **unidade natural**: reais em reais, contagem em unidades, porcentagem como **fração** (0,958), tempo em minutos.
- Formate **só na exibição**, com uma função única por unidade. Misturar "dados em milhares" com um formatador que também divide por mil gerou "R$ 182M" no lugar de "R$ 182k" em dois painéis diferentes.
- Formatos (pt-BR): moeda compacta `R$ 716,6k` / `R$ 2,04M`; moeda cheia `R$ 716.582`; `69,1%`; `22 min` / `1h 05m`; pontos `56,1`.

## Variação (delta)

- **Porcentagem** → diferença em **pontos percentuais** (`+1,5 p.p.`), nunca % de %.
- **Score** (NPS, CSAT) → diferença absoluta em **pontos** (`+8,0 pts`).
- **Demais** → variação %; **mas**, se a base for zero, tiver sinal oposto ou for menor que 25% do valor atual, mostre a **diferença absoluta** (`+R$ 55,6k`). Senão aparecem absurdos como "+1054%".
- **Favorável** = `diff × dir > 0`. Custo, churn, tempo e erros têm `dir = -1`.
- Sem base (primeiro período, ano anterior sem histórico, métrica sem meta) → "sem base" / "—", nunca 0%.

## Comparações

- **Período anterior**, **mesmo período do ano anterior** (`yearLag`) e **meta/orçado**. Esconda a opção sem dados.
- A comparação escolhida vale para tudo na tela: cartões, tabela, ponte, quebra, insights e resumo.

## Projeção

- Regressão linear dos últimos 12 períodos (mínimo 3); faixa de 80% = ±1,28 × erro-padrão da previsão.
- Mostre sempre a faixa e rotule a área como "projeção". Nunca apresente projeção como fato.

## Insights (sem conselho genérico)

Todo insight cita **números exatos** e a comparação usada. Regras automáticas do motor:
1. **Ritmo**: variação média dos últimos 3 períodos contra os 3 anteriores (acelerando ou desacelerando).
2. **Maior desvio** contra a base escolhida entre as linhas da tabela.
3. **Fora do padrão**: z-score ≥ 1,8 em relação aos últimos 12 períodos.
4. **Quem mais moveu o total** na dimensão de quebra.
5. **Melhor e pior período** do indicador principal em 12 períodos.
6. **Projeção** do indicador principal com faixa.

Regras de domínio entram em `CONFIG.insights` (ex.: runway, capex, Rule of 40). Exemplos de bons insights: "Marketing R$ 182k em Mai/26, +134,8% acima da média da categoria"; "Cada R$ 1 de receita nova custou R$ 0,33 de opex". Um exemplo ruim: "Considere otimizar custos".

## Resumo executivo (3 pontos)

- **Melhorou**: maior movimento favorável entre as métricas dos níveis 1 e 2.
- **Piorou**: maior movimento desfavorável ou, se nada piorou, o avanço mais fraco, dito assim.
- **Exige atenção**: regra de domínio (`attention`) ou, na falta dela, a maior anomalia.

## Dados de exemplo

- Deterministas (seno/crescimento composto, sem `Math.random`), para que o painel seja igual a cada abertura e os testes sejam reproduzíveis.
- Plausíveis para o domínio, com 1 ou 2 eventos que acionem os insights (um pico de custo, uma queda, um incidente).
- Isolados no topo e marcados como exemplo na página.
