# Armadilhas que já aconteceram

Cada item custou uma rodada com o usuário. O verificador (`scripts/check.mjs`) pega os marcados com ✔; os outros só aparecem olhando o print.

| Sintoma | Causa | Prevenção |
|---|---|---|
| ✔ Painel inteiro em branco/escuro, sem erro no console | `</script>` final esquecido; o navegador não roda o script | Feche o script; o verificador acusa conteúdo não revelado |
| ✔ "Continua escuro" | Página seguia `prefers-color-scheme` e o app do usuário é escuro | Tema claro travado (design-system.md) |
| ✔ Seções invisíveis até rolar | Revelação só por IntersectionObserver | Revele tudo no carregamento (ou com fallback de ~1,5 s); o scroll só antecipa |
| ✔ Rolagem horizontal no celular | Tabela dentro de item de grid sem `min-width: 0` nem `overflow-x: auto` | Envolva tabelas e gráficos largos; `.card { min-width: 0 }` |
| "R$ 182.00M" em vez de "R$ 182k" | Dados em milhares + formatador que também divide por mil | Valores na unidade natural; formatar só na exibição |
| "+1054%" no comparativo | % sobre base minúscula ou de sinal oposto | Regra de base pequena → diferença absoluta (data-rules.md) |
| Runway mostrando número quando deveria ser ∞ | Animação de contagem anterior continuou e sobrescreveu o "∞" | Contagem cancelável; cancele antes de escrever valor fixo |
| Cenário Base com runway ∞ num demo de runway | Dados de exemplo com crescimento que zera a queima | Ajuste os exemplos para acionar o que o painel quer mostrar |
| Barras de segmento vazias | `<span>` inline ignora `width`/`height` | `display: block` em trilhas e preenchimentos |
| Texto gigante no gráfico | `viewBox` pequeno esticado para a largura total | viewBox proporcional ao espaço real |
| Rótulo cortado na borda do gráfico | `padR` pequeno para o último rótulo | Folga de ~30px à direita |
| 6º cartão "sumido" no print | Print tirado no meio da animação em sequência | Espere o fim da animação (≈2,5 s) antes do print |
| PDF com frase espaçada letra por letra | Caractere fora do Latin-1 (`→`) nas fontes padrão do jsPDF | `pdfSafe` em todo texto do PDF |
| PDF não gera no teste local | Chromium local não alcança a CDN | Sirva `node_modules/jspdf` via `page.route` (o check.mjs faz isso) |
| "−NaN%" num índice | Acesso a `row.campo` em vez de `row.v.campo` na config | Olhe os índices no print; teste com a comparação "ano anterior" |
| Uptime "−0,0 p.p." | 1 casa decimal para métrica que varia na 2ª | `decimals: 2` na métrica |
| NPS "+16,7%" | Score comparado em % | `unit: "score"` (variação em pontos) |
| Waterfall pintando aumento de custo de verde | Cor pela direção do número, não da métrica | Favorável = `efeito × dir do alvo > 0` |
| Gráfico com "Caixa ÷10" | Duas unidades forçadas no mesmo eixo | Um eixo por unidade; separe em outro gráfico ou no painel lateral |
| Barra de progresso do scroll escondida | Barra fixa sem `env(safe-area-inset-top)` | Barras fixas somam a safe area no padding |

## Antes de publicar, olhe o print procurando

`NaN`, `undefined`, `Infinity`, `—` onde deveria haver número, ordem de grandeza estranha, barras vazias, rótulos sobrepostos ou cortados, cartão com a cor de status errada, texto branco sobre fundo claro.
