#!/usr/bin/env node
// Verificação headless de um painel HTML antes de publicar.
// Uso: node scripts/check.mjs <painel.html | http://localhost:3000/rota> [--shot pasta] [--click "seletor"]...
//
// O que checa (cada item virou regra depois de um bug real):
//  1. erros de JS e de console (ex.: </script> faltando deixa a página em branco sem erro nenhum)
//  2. o script rodou (há conteúdo renderizado dentro de .wrap)
//  3. fundo claro mesmo com o host em tema escuro (luminância do fundo do body)
//  4. nada preso em opacity 0 depois das animações (.reveal/.in)
//  5. sem rolagem horizontal a 390px
//  6. cada seletor passado em --click funciona sem erro
// Salva prints de desktop e celular para olhar UMA vez antes de publicar.
//
// Requer playwright (npm i playwright). Em ambientes com Chromium pré-instalado,
// defina PW_CHROMIUM=/caminho/para/chromium. Bibliotecas de CDN (jsPDF) podem não carregar
// offline: se existir node_modules/jspdf, a requisição é servida localmente.
import fs from "fs";
import path from "path";

import { createRequire } from "module";
let chromium;
try { ({ chromium } = await import("playwright")); }
catch {
  try { ({ chromium } = createRequire(path.join(process.cwd(), "noop.js"))("playwright")); }
  catch { console.error("Instale o playwright na pasta atual: npm i playwright"); process.exit(2); }
}

const args = process.argv.slice(2);
const file = args.find(a => !a.startsWith("--") && args[args.indexOf(a) - 1] !== "--shot" && args[args.indexOf(a) - 1] !== "--click");
if (!file) { console.error("uso: node scripts/check.mjs painel.html [--shot pasta] [--click seletor]"); process.exit(2); }
const shotDir = args.includes("--shot") ? args[args.indexOf("--shot") + 1] : (/^https?:/.test(file) ? process.cwd() : path.dirname(path.resolve(file)));
const clicks = args.map((a, i) => a === "--click" ? args[i + 1] : null).filter(Boolean);
const isURL = /^https?:\/\//.test(file);
const url = isURL ? file : "file://" + path.resolve(file);
const exe = process.env.PW_CHROMIUM || (fs.existsSync("/opt/pw-browsers/chromium") ? "/opt/pw-browsers/chromium" : undefined);
const localJsPDF = ["node_modules/jspdf/dist/jspdf.umd.min.js", path.join(path.dirname(new URL(import.meta.url).pathname), "../node_modules/jspdf/dist/jspdf.umd.min.js")].find(p => fs.existsSync(p));

const browser = await chromium.launch(exe ? { executablePath: exe } : {});
const problems = [];
async function open(viewport){
  const page = await browser.newPage({ colorScheme: "dark", viewport });
  if (localJsPDF) await page.route("**/jspdf.umd.min.js", r => r.fulfill({ path: localJsPDF, contentType: "application/javascript" }));
  const errs = [];
  page.on("pageerror", e => errs.push("pageerror: " + e.message));
  page.on("console", m => { if (m.type() === "error" && !/ERR_TUNNEL|ERR_NAME|Failed to load resource/.test(m.text())) errs.push("console: " + m.text()); });
  await page.goto(url, { waitUntil: "load" });
  await page.waitForTimeout(2600);
  return { page, errs };
}

const { page, errs } = await open({ width: 1280, height: 900 });
const info = await page.evaluate(() => {
  const bg = getComputedStyle(document.body).backgroundColor;
  const m = bg.match(/\d+(\.\d+)?/g) || [0, 0, 0, 0];
  const [r, g, b, a] = m.map(Number);
  const lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255;
  const wrap = document.querySelector(".wrap") || document.body;
  const stuck = [...document.querySelectorAll(".reveal, .ins, .kpi, .tile, .panel, .card")]
    .filter(el => !el.hidden && el.offsetParent !== null && parseFloat(getComputedStyle(el).opacity) < 0.99).length;
  return { bg, lum, alpha: a === undefined ? 1 : a, textLen: wrap.innerText.trim().length, stuck, title: document.title };
});
if (info.textLen < 50) problems.push("pouco conteúdo renderizado: o script provavelmente não rodou (</script> faltando? erro de sintaxe?)");
if (info.alpha === 0) problems.push("body sem cor de fundo sólida: defina background-color explícito");
else if (info.lum < 0.6) problems.push(`fundo escuro com host em tema escuro (luminância ${info.lum.toFixed(2)}): trave o tema claro`);
if (info.stuck) problems.push(`${info.stuck} elemento(s) presos invisíveis (opacity < 1) após as animações: o script parou antes de revelar? Veja </script> e erros de sintaxe`);

for (const sel of clicks) {
  try { await page.click(sel, { timeout: 3000 }); await page.waitForTimeout(500); await page.keyboard.press("Escape"); }
  catch (e) { problems.push(`clique falhou em ${sel}: ${e.message.split("\n")[0]}`); }
}
problems.unshift(...errs); // erros de JS do carregamento e dos cliques

fs.mkdirSync(shotDir, { recursive: true });
const base = isURL ? "painel" : path.basename(file, ".html");
await page.screenshot({ path: path.join(shotDir, `${base}-desktop.png`), fullPage: true });

const mob = await open({ width: 390, height: 844 });
const overflow = await mob.page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
if (overflow > 1) problems.push(`rolagem horizontal de ${overflow}px no celular (390px)`);
if (mob.errs.length) problems.push(...mob.errs.map(e => "celular " + e));
await mob.page.screenshot({ path: path.join(shotDir, `${base}-mobile.png`), fullPage: false });
await browser.close();

console.log(`título: ${info.title}`);
console.log(`fundo: ${info.bg} (luminância ${info.lum.toFixed(2)}) · texto renderizado: ${info.textLen} caracteres`);
console.log(`prints: ${path.join(shotDir, base)}-desktop.png / -mobile.png`);
if (problems.length) { console.log("\nPROBLEMAS:"); [...new Set(problems)].forEach(p => console.log(" - " + p)); process.exit(1); }
console.log("\nOK: nenhum problema encontrado");
