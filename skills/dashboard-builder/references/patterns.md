# Catálogo de padrões e templates

Todos os templates em `assets/templates/` são páginas completas, testadas e com tema claro travado. Copie o arquivo inteiro, troque os dados do topo e adapte. Não reescreva do zero um padrão que já existe aqui.

| Template | Visualização central | Use quando | Interações |
|---|---|---|---|
| `signal-command-center.html` ★ | Sinal principal + fila "Atenção agora" + recomendações com aprovação | Produto que diz o que olhar agora (MAE, copiloto de operação); várias entidades cruzadas (clientes, fornecedores, produtos, conversas) | Menu com 15 telas (Financeiro no nível CFO Pro, Company DNA, Dados & integrações com abas), modo demo isolado, 5 temas, evidências, perfis "O que o MAE percebeu", aprovar/rejeitar/executar/resultado, aprendizado, perguntas com fontes |
| `cfo-pro-analyst.html` ★ | KPIs em 3 níveis, tabela de variação, ponte, projeção, segmentos | Visão executiva de qualquer operação com histórico e meta (o motor é a versão genérica dele) | Filtro período/base, drill em tudo, scrubber, legenda, CSV/PDF, parecer Claude |
| `networth-editable.html` ★ | Balança ativos × passivos, donut, scrubber, anel de progresso | Composição de um todo + evolução + meta de progresso (patrimônio, carteira, alocação de verba, estoque) | Editar valores ao vivo, clicar fatia, abrir item (juros), arrastar linha do tempo |
| `runway-scenarios.html` | Projeção com 3 cenários, sliders de premissas | Simulador "e se": runway, capacidade, metas de venda, precificação | Sliders, cenários clicáveis, legenda focável, restaurar |
| `anomaly-insights.html` | Linha com marcadores de anomalia + cartões de insight | Detecção de fora do padrão, quedas, custos acelerando | Varredura animada, insight clicável que destaca o ponto, "reanalisar" |
| `cashflow-sankey.html` | Diagrama Sankey de fluxo | Dinheiro, usuários, tráfego ou materiais fluindo de origens para destinos | Tooltip por fluxo, campo de mínimo com alerta, projeção |
| `budget-bullets-scroll.html` | Bullet charts por item + scrollytelling | Realizado × meta por categoria, com semáforo e estouros | Scroll revela, anel de utilização, projeção de fechamento |
| `dre-waterfall.html` | Waterfall de resultado + tabela DRE | Decompor um resultado em somas e subtrações (DRE, margem, funil de receita) | Toggle vs anterior/orçado, período |
| `cfo-bento.html` | Bento com tiles em gradiente e gauges | Visão de uma página mais visual e menos densa | Toggle de comparação |

★ = favoritos do usuário.

## Padrões reutilizáveis (onde estão)

- **Contagem de-para cancelável** (`animNum` no motor; `animateNum` + `stopAnim` no runway): anima do valor anterior ao novo e cancela a animação em voo antes de iniciar outra ou de escrever um valor fixo (∞, "—"). Sem cancelar, a animação antiga sobrescreve o valor novo.
- **Painel lateral de detalhe** (`openDrawer`, no motor e no CFO Pro): título, gráfico de histórico com linha de meta tracejada, nota com média e comparação anual, tabela dos últimos 12 períodos. Fecha com ✕, clique fora e Esc.
- **Scrubber de linha do tempo** (motor, networth): um `input range` mais faixas de clique no gráfico; pontos seguem o cursor; leitura com valores e faixa de projeção.
- **Projeção com faixa** (motor): regressão linear dos últimos 12, faixa de 80%, área de projeção sombreada e rotulada.
- **Tabela de variação com formatação condicional** (motor): fundo verde/vermelho com intensidade proporcional ao desvio e sinal ajustado pela direção da métrica.
- **Ponte / waterfall** (motor, DRE): barras flutuantes com conectores tracejados; total em cor de destaque; resíduo vira "Outros".
- **Sankey** (cashflow): bandas com curva de Bézier entre nós empilhados sem folga; largura = valor × escala única.
- **Bullet chart** (budget): trilha, zona de estouro e marcador da meta na mesma posição em todas as linhas para leitura rápida.
- **Editor ao vivo** (networth): inputs com debounce de 180 ms que recalculam e reanimam tudo.
- **Varredura "IA analisando"** (anomaly): linha que atravessa o gráfico, barra de progresso, insights surgindo em sequência.
- **Textura de concreto** (anomaly): SVG `feTurbulence` em data URI como `background-image`.

## Qual escolher

0. O usuário quer que o sistema aponte o que merece atenção e proponha ações, não que mostre totais? → **signal-command-center** (signal-first.md).
1. É uma série temporal de métricas com meta? → **motor**.
2. O usuário quer mexer em premissas e ver o efeito? → **runway-scenarios**.
3. É composição de um todo que o usuário atualiza à mão? → **networth-editable**.
4. É "para onde vai" (origem → destino)? → **cashflow-sankey**.
5. São muitos itens contra uma meta cada? → **budget-bullets-scroll**.
6. O pedido é "me diga o que está errado nos números"? → **anomaly-insights** (ou os insights do motor).
7. É decompor um resultado em parcelas? → **ponte do motor** ou **dre-waterfall**.
