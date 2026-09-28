# Painel de comando orientado a sinais (Caminho C)

Use quando o produto deve dizer **o que merece atenção agora**, não exibir totais. Foi o formato escolhido para o MAE ("sistema operacional de inteligência da empresa"). Template: `assets/templates/signal-command-center.html`.

Dashboard tradicional: "Receita R$ 482 mil · 327 clientes · 18 fornecedores".
Painel de sinais: "3 clientes importantes estão reduzindo compras. Por quê: 2 mencionaram preço. Impacto: R$ 38 mil/mês. O que fazer: revisar a negociação. [Ver clientes] [Ver evidências]".

O número vira **evidência**, não manchete.

## Anatomia da tela inicial

1. **Saudação e escopo da análise**: "Bom dia, João. O MAE leu 1.284 mensagens, 6 meses de vendas…"
2. **Cobertura dos dados**: cada fonte com status (tempo real, sincronizado há X, desatualizado, não conectado). Sem isso, "nada a relatar" pode ser falta de dado.
3. **Sinal principal (herói)**: título do sinal, os porquês com números, impacto estimado (com contagem animada), o que fazer, confiança, botões [Ver X] e [Ver evidências].
4. **Atenção agora**: fila de sinais ordenada por impacto, com barra de severidade, fontes e confiança. Clique abre as evidências.
5. **Hoje na empresa**: uma linha por área, resumida pelo que merece olhar ("3 em atenção · 12 ativos"), clicável para a área. Abaixo, um insight de concentração ou mix que um total esconderia.
6. **Aguardando aprovação**: cartões de recomendação com Aprovar e Rejeitar.
7. **Ciclo recente**: ações e resultados.
8. **Atalho para perguntas**: sugestões clicáveis.

## Área financeira dentro do painel de sinais

Sinal sem número não convence o dono da empresa: ele quer ver faturamento e lucro. O template traz a tela **Financeiro** com a profundidade do Cockpit do CFO Pro:
- KPIs em 3 níveis (faturamento, lucro líquido, caixa → margens, despesas, ticket médio → índices);
- filtros de mês e de base (mês anterior, ano anterior, meta), variação com formatação condicional, ponte do lucro;
- tendência de 24 meses com projeção e scrubber, faturamento por segmento com detalhe até o cliente;
- resumo executivo, parecer com Claude, CSV e PDF.

O que a diferencia do motor isolado:
- abre com **"O que o MAE percebeu no financeiro"** (margem, concentração do crescimento, lucro vs meta), no mesmo tom dos sinais;
- os números saem das **mesmas entidades** do resto do painel (o faturamento dos últimos meses é a soma dos clientes), então tudo bate entre telas;
- quedas de margem viram **sinal na tela inicial**, com evidências ligando CMV a reajustes de fornecedores, e o "Pergunte à empresa" responde sobre lucro e margem.

Para outro domínio, troque `FSEGS` (segmentos e quais entidades compõem cada um) e as premissas de custo em `FIN`.

## Temas

O template traz um seletor de tema no menu com 5 opções: **bege** (padrão), branco, preto, azul e vermelho. Cada tema é um bloco `:root[data-theme="…"]` que redefine os tokens, inclusive os gradientes (`--hero`, `--fhero`, `--falt`, `--hero-glow`). A escolha fica salva em `localStorage` (`mae-theme`). Texto sobre fundo colorido continua `#fff`; todo o resto usa tokens, para que nenhum tema quebre o contraste. O preto é opcional: o padrão continua claro.

## Regras

- **Todo sinal é calculado dos dados**, por uma função com limiar explícito (ex.: média de 2 meses ≥ 20% abaixo da de 4 meses, entre clientes com base ≥ R$ 15 mil). Nunca escreva sinais fixos no HTML: os números precisam bater entre a tela inicial, as listas, os perfis e as respostas.
- **Evidência em tudo.** Cada sinal abre uma lista do que o sustenta: dados com período e fonte, trechos de conversa com data e canal, e **como o impacto foi calculado** (fórmula em uma frase, com o que ela não inclui).
- **Confiança = quantidade de tipos de evidência independentes** (ex.: vendas, conversas, contrato → alta ≥ 3, média 2, baixa 1). Mostre sempre ao lado do sinal.
- **Priorize o que tem explicação.** Entre quedas parecidas, destaque a que tem causa nas conversas; uma frase como "clientes citaram preço 0 vezes" nunca deve aparecer.
- **Governança do ciclo**: sinal → recomendação → **aprovação humana** → ação → resultado → aprendizado.
  - Estados da recomendação: `pendente → aprovada → executada → concluída` ou `pendente → rejeitada`.
  - Nada é executado sem o clique em "Executar" depois de aprovar. Mostre a mensagem ou tarefa preparada antes.
  - Rejeitar pede **motivo** (lista curta). O motivo alimenta o aprendizado.
  - Toda ação executada pede o **resultado** (deu certo, recusou, sem resposta).
- **Aprendizado**: taxa de sucesso por tipo de ação (histórico + novos resultados), usada para ordenar e justificar recomendações ("funcionou em 60% das vezes"), sem dar autonomia ao sistema.
- **Perfis de entidade** (cliente, fornecedor, produto) abrem com **"O que o MAE percebeu"** antes dos números: frases geradas por regras sobre os dados daquela entidade, com um fallback honesto ("relacionamento estável, sem alertas").
- **Pergunte à empresa**: responda só com dados disponíveis; mostre "Evidências usadas" e "Fontes"; quando não houver dado, diga isso em vez de inventar. No protótipo, perguntas são roteadas por palavras-chave para funções que consultam os mesmos dados; no produto, isso vem do backend.
- **Itens de menu ainda não construídos** ficam visíveis, desabilitados e com "em breve". Nunca abra uma tela vazia.
- **Protótipo com estado**: guarde o estado do ciclo em `localStorage` (com try/catch) e ofereça "Reiniciar demonstração".

## Modelo de dados do template

```
CLIENTES     [{id, nome, seg, rec:[6 meses], ult, prods, contrato?, conv:[{dt, txt, tags, tema?, prod?, valor?}]}]
FORNECEDORES [{id, nome, cat, preco:[índice 8 meses], part, atrasos, compras}]
PRODUTOS     [{id, nome, cat, qtd:[6 meses], forn}]
FONTES       [{nome, tipo, status: live|ok|stale|off, sinc, vol}]
HIST         [{tipo, titulo, res, det}]    // ciclos anteriores para o aprendizado
A = análise derivada (reduz, contratos, recl, reajustes, prodQueda, oport…)
SIGNALS = buildSignals(A) · RECS = buildRecs(A)
```

Para outro domínio, troque as entidades e reescreva `A`, `buildSignals` e `buildRecs`. A casca (menu, gaveta, cartões, ciclo, perguntas) continua a mesma.

## Verificação específica

Além do `check.mjs`, rode um teste de fluxo (Playwright) que:
- percorra todas as rotas procurando `NaN`, `undefined` e `Infinity` no texto;
- aprove, rejeite com motivo, execute, registre o resultado e confirme que Ações, Resultados e Aprendizado mudaram;
- clique em cada pergunta sugerida, faça uma pergunta livre e uma fora do escopo (a resposta deve admitir que não sabe);
- abra um perfil pela busca.

Esse teste pegou, no MAE: plural quebrado ("reclamaçãoões"), sinal destacando o produto sem explicação, data de contrato no passado e comparação "de 4 para 4 (+0%)" descrita como alta.
