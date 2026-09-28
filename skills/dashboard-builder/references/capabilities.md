# Exportação e parecer com Claude (capacidades do Artifact)

Um Artifact roda num sandbox: `<a download>`, `window.print()` e `fetch` externo não funcionam. Para exportar arquivos e chamar o Claude, a página declara **capacidades** no publish e as obtém em tempo de execução. Se a sessão tiver a skill `artifact-capabilities`, carregue-a para ver o contrato atualizado; o resumo abaixo reflete o runtime 0.2.61.

## Declarar no publish

```
Artifact(file_path=..., capabilities={"downloads": true, "sample": {}})
```
Sem declarar, `claude.use(...)` resolve `null` e os botões continuam ocultos (a página funciona igual).

## Obter em tempo de execução

```js
const RT = (typeof window.claude !== "undefined" && window.claude && typeof window.claude.use === "function") ? window.claude : null;
if (RT) {
  RT.use("downloads").then(d => { DL = d; if (d) showExportButtons(); }).catch(() => {});
  RT.use("sample").then(s => { SAMPLE = s; if (s) showAIBox(); }).catch(() => {});
}
```
Fora do viewer (arquivo local, headless) `window.claude` não existe e nada aparece. Projete para a ausência.

## Download (CSV/PDF)

```js
await DL.save({ filename: "painel-set-26.pdf", data: arrayBufferOuStringOuBlob });
```
- O usuário vê uma confirmação e pode recusar (`declined`); nunca repita sozinho.
- Extensões permitidas incluem `csv`, `pdf`, `xlsx`, `json`, `png`, `html`, `zip`, `md`, `txt`.
- Erros `unavailable`, `not_granted`, `capability_disabled` e `capability_removed` → esconda os botões.

**CSV para Excel em pt-BR**: separador `;`, decimal com vírgula, BOM `﻿` no início, `\r\n` entre linhas. Exporte todos os períodos e métricas (a tabela, não a tela).

**PDF com jsPDF** (`https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js`, global `window.jspdf.jsPDF`):
- Monte um relatório (faixa de título, cartões de KPI, tabela de variação, mini gráfico de barras desenhado com `rect`, resumo, insights, parecer se houver, rodapé "página X de Y"). Não tente capturar a tela.
- As fontes padrão só têm Latin-1: **passe todo texto por `pdfSafe`**, que troca `→ − ▲ ▼ ≥ ÷ “ ” …` e remove tags. Um único `→` fez o jsPDF espaçar a frase inteira letra por letra.
- `doc.splitTextToSize` para quebrar parágrafos; `doc.addPage()` quando `y > 275`.
- Retorne `doc.output("arraybuffer")` e passe ao `DL.save`.

## Parecer com Claude (`sample`)

```js
const ctl = new AbortController();
const { text, truncated } = await SAMPLE(prompt, { signal: ctl.signal, onText: ({ text }) => out.textContent = text });
```
- Só em clique ("Gerar parecer"), nunca no carregamento ou em loop. Consome o plano **de quem está vendo**; o primeiro uso pede consentimento.
- Mostre "Pensando…" até o primeiro `onText`; ofereça "Parar" (`ctl.abort()`, um controlador novo por chamada).
- O prompt leva tudo: papel, período, base de comparação, regras de formato (≤ 180 palavras, 3 parágrafos, números exatos, sem markdown) e os dados da tela (linhas da tabela, quebra, insights já calculados).
- Erros: `cancelled` → "Parado."; `not_granted`, `sampling_disabled`, `not_declared` → esconda a caixa; `rate_limited` → avise e deixe o usuário tentar depois.
- O parecer gerado entra no PDF.

## Testar sem o viewer

Injete um runtime falso antes do carregamento (Playwright `addInitScript`) que implemente `use("downloads")` gravando o arquivo em `window.__saved` e `use("sample")` devolvendo um texto fixo. Assim dá para validar o CSV (cabeçalho, BOM) e o PDF (abrir com PyMuPDF e renderizar a página 1) sem clicar em confirmações reais. Diga ao usuário que a confirmação real não foi exercitada.
