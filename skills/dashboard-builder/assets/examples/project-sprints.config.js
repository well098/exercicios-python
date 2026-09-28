// Exemplo de projeto por sprint (periodType "label", sem comparação anual). Os números do "MAE" são INVENTADOS:
// é um molde para trocar pelos dados reais do projeto. Gere com:
//   python scripts/new_dashboard.py assets/examples/project-sprints.config.js painel-projeto.html
const CONFIG = (() => {
  const FRENTES = ["Backend", "Frontend", "Infra"];
  const TOTAL_ESCOPO = 160;          // itens de escopo do projeto (total)
  const ORCAMENTO_TOTAL = 2000000;   // orçamento do projeto (R$)
  const SPRINTS_PLANO = 16;          // sprints previstos
  const TAXA = { Backend: 165, Frontend: 150, Infra: 185 }; // R$/hora
  // Plano por sprint e realizado (exemplo). Sprint 9 teve incidente de infra; 11-12 com retrabalho de bugs.
  const plan = [8, 9, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11];
  const done = [7, 9, 9, 11, 10, 11, 12, 10, 6, 9, 8, 9];
  const lead = [6.5, 6.1, 6.4, 5.8, 5.9, 5.5, 5.2, 5.8, 8.9, 7.4, 7.9, 8.3];
  const bugs = [4, 6, 7, 6, 8, 7, 6, 9, 15, 14, 17, 19];
  const hB = [310, 320, 330, 335, 340, 345, 340, 350, 360, 370, 380, 395];
  const hF = [200, 220, 240, 250, 260, 265, 270, 270, 250, 265, 280, 290];
  const hI = [90, 85, 80, 80, 85, 80, 80, 90, 190, 150, 120, 115];
  const infraCloud = [9000, 9200, 9400, 9500, 9800, 10000, 10100, 10300, 16800, 13200, 12400, 12100];
  const rows = [];
  let escopo = 0, escopoPlan = 0, acum = 0, acumPlan = 0;
  for (let i = 0; i < plan.length; i++) {
    escopo += done[i]; escopoPlan += plan[i];
    const dim = {
      Backend:  { horas: hB[i], custoPessoas: hB[i] * TAXA.Backend },
      Frontend: { horas: hF[i], custoPessoas: hF[i] * TAXA.Frontend },
      Infra:    { horas: hI[i], custoPessoas: hI[i] * TAXA.Infra },
    };
    const bdim = { Backend: { horas: 340 }, Frontend: { horas: 260 }, Infra: { horas: 85 } };
    const custoPessoas = FRENTES.reduce((s, k) => s + dim[k].custoPessoas, 0);
    const custoSprint = custoPessoas + infraCloud[i];
    acum += custoSprint;
    const orcSprint = ORCAMENTO_TOTAL / SPRINTS_PLANO;
    acumPlan += orcSprint;
    const horas = hB[i] + hF[i] + hI[i];
    rows.push({
      p: "S" + String(i + 1).padStart(2, "0"),
      v: { entregas: done[i], escopo: escopo / TOTAL_ESCOPO, leadTime: lead[i], bugs: bugs[i], custoAcum: acum, orcadoAcum: acumPlan,
           custoSprint, custoPessoas, custoCloud: infraCloud[i], horas, aderencia: done[i] / plan[i] },
      b: { entregas: plan[i], escopo: escopoPlan / TOTAL_ESCOPO, leadTime: 6, bugs: 8, custoAcum: acumPlan, custoSprint: orcSprint,
           custoPessoas: orcSprint - 10000, custoCloud: 10000, horas: 685, aderencia: 1 },
      dim, bdim,
    });
  }
  const pct = (c, v) => c.fmt("percent", v, false, 0);
  return {
    title: "Projeto MAE por Sprint",
    eyebrow: "Projeto MAE · acompanhamento por sprint",
    subtitle: "Entregas, escopo, qualidade, custo e esforço sprint a sprint. Clique em qualquer indicador ou frente para abrir o histórico.",
    footnote: `Dados de exemplo. Escopo total de ${TOTAL_ESCOPO} itens, ${SPRINTS_PLANO} sprints previstos, orçamento de R$ 2,0M. Horas × taxa por frente + nuvem = custo do sprint.`,
    palette: "eletrico",
    currency: "BRL",
    periodType: "label",
    budgetLabel: "Plano",
    metrics: {
      entregas:     { label: "Entregas concluídas",      unit: "number",   dir: 1, absDelta: true, decimals: 0 },
      aderencia:    { label: "Entregue ÷ planejado",     unit: "percent",  dir: 1, decimals: 0 },
      escopo:       { label: "% do escopo concluído",    unit: "percent",  dir: 1 },
      leadTime:     { label: "Lead time",                unit: "days",     dir: -1 },
      bugs:         { label: "Bugs abertos",             unit: "number",   dir: -1, absDelta: true, decimals: 0 },
      custoAcum:    { label: "Custo acumulado",          unit: "currency", dir: -1 },
      orcadoAcum:   { label: "Orçado acumulado",         unit: "currency", dir: -1, noBudget: true },
      custoSprint:  { label: "Custo do sprint",          unit: "currency", dir: -1 },
      custoPessoas: { label: "Custo de pessoas",         unit: "currency", dir: -1 },
      custoCloud:   { label: "Custo de nuvem",           unit: "currency", dir: -1 },
      horas:        { label: "Horas no sprint",          unit: "number",   dir: 0 },
    },
    rows,
    tiers: {
      labels: ["1 · Entrega e avanço", "2 · Qualidade, prazo e custo", "3 · Saúde do projeto"],
      t1: [{ key: "entregas", title: "Entregas no sprint" }, { key: "escopo" }, { key: "custoAcum", style: "alt", title: "Custo acumulado vs orçado" }],
      t2: ["leadTime", "bugs", "custoSprint", "horas"],
    },
    tileFoot: (key, c) => {
      const v = c.row.v, b = c.row.b;
      if (key === "entregas") return `planejadas <b>${b.entregas}</b> · ${pct(c, v.aderencia)} do plano`;
      if (key === "escopo") return `plano ${pct(c, b.escopo)} · faltam ${Math.round((1 - v.escopo) * TOTAL_ESCOPO)} itens`;
      if (key === "custoAcum") { const d = v.custoAcum - v.orcadoAcum; return `orçado ${c.fmt("currency", v.orcadoAcum)} · <b>${d >= 0 ? "+" : "−"}${c.fmt("currency", Math.abs(d))}</b> ${d >= 0 ? "acima" : "abaixo"}`; }
      if (key === "leadTime") return `meta até ${c.num(b.leadTime, 0)} dias`;
      if (key === "bugs") return `limite ${b.bugs} abertos`;
      return "";
    },
    ratios: (c) => {
      const v = c.row.v, i = c.i;
      const ult3 = c.rows.slice(Math.max(0, i - 2), i + 1);
      const vel = ult3.reduce((s, r) => s + r.v.entregas, 0) / ult3.length;
      const faltam = TOTAL_ESCOPO * (1 - v.escopo);
      const sprintsRest = Math.ceil(faltam / vel);
      const fim = i + 1 + sprintsRest;
      const cpi = v.custoAcum ? (v.escopo * ORCAMENTO_TOTAL) / v.custoAcum : null; // valor agregado ÷ custo real
      const eac = cpi ? ORCAMENTO_TOTAL / cpi : null;
      return [
        { label: "Velocidade (média 3 sprints)", value: c.num(vel, 1) + " itens", note: `plano ${c.num(TOTAL_ESCOPO / SPRINTS_PLANO, 1)} itens/sprint`, status: vel >= TOTAL_ESCOPO / SPRINTS_PLANO ? "good" : vel >= 9 ? "warn" : "bad" },
        { label: "Término projetado", value: "S" + fim, note: `no ritmo atual faltam ${sprintsRest} sprints · plano S${SPRINTS_PLANO}`, status: fim <= SPRINTS_PLANO ? "good" : fim <= SPRINTS_PLANO + 1 ? "warn" : "bad" },
        { label: "Eficiência de custo (CPI)", value: cpi == null ? "—" : c.num(cpi, 2), note: "escopo entregue × orçamento ÷ custo real", status: cpi >= 1 ? "good" : cpi >= 0.9 ? "warn" : "bad" },
        { label: "Custo final projetado (EAC)", value: eac == null ? "—" : c.fmt("currency", eac), note: `orçamento ${c.fmt("currency", ORCAMENTO_TOTAL)}`, status: eac <= ORCAMENTO_TOTAL ? "good" : eac <= ORCAMENTO_TOTAL * 1.1 ? "warn" : "bad" },
      ];
    },
    table: [
      { key: "entregas", style: "total" }, { key: "aderencia", style: "sub" },
      { key: "escopo", style: "total" },
      { key: "leadTime", style: "total" }, { key: "bugs", style: "total" },
      { key: "custoSprint", style: "total" }, { key: "custoPessoas", style: "sub" }, { key: "custoCloud", style: "sub" },
      { key: "custoAcum", style: "total" }, { key: "horas", style: "total" },
    ],
    bridge: { title: "Ponte do custo do sprint", target: "custoSprint", parts: [
      { key: "custoPessoas", sign: 1, label: "Pessoas" }, { key: "custoCloud", sign: 1, label: "Nuvem" } ] },
    trend: { title: "Custo acumulado vs orçado acumulado", series: ["custoAcum", "orcadoAcum"], horizon: 4 },
    breakdown: { title: "Horas por frente", dimension: "frente", metric: "horas", secondary: "custoPessoas", secondaryLabel: "custo de pessoas",
      members: [{ k: "Backend", color: "--c1" }, { k: "Frontend", color: "--c2" }, { k: "Infra", color: "--c3" }] },
    attention: (c) => {
      const v = c.row.v, b = c.row.b;
      const tend = c.rows.slice(Math.max(0, c.i - 3), c.i + 1).map(r => r.v.bugs);
      if (v.bugs > b.bugs && tend.length > 1 && tend[tend.length - 1] > tend[0])
        return { t: `Risco principal: qualidade (${v.bugs} bugs abertos)`, b: `Bugs subiram de ${tend[0]} para ${v.bugs} em ${tend.length - 1} sprints (limite ${b.bugs}). O retrabalho puxa o lead time para ${c.num(v.leadTime, 1)} dias e derruba a entrega para ${pct(c, v.aderencia)} do plano.` };
      if (v.escopo < b.escopo - 0.05) return { t: `Escopo ${pct(c, v.escopo)} vs plano ${pct(c, b.escopo)}`, b: `Atraso de ${Math.round((b.escopo - v.escopo) * TOTAL_ESCOPO)} itens.` };
      return null;
    },
    insights: (c) => {
      const v = c.row.v, b = c.row.b, out = [];
      const atraso = Math.round((b.escopo - v.escopo) * TOTAL_ESCOPO);
      out.push({ cls: atraso > 0 ? "bad" : "good", t: "Escopo vs plano", h: atraso > 0 ? `<b>${atraso} itens atrasados</b>: ${pct(c, v.escopo)} concluído contra ${pct(c, b.escopo)} planejado.` : `Escopo em dia ou adiantado (${pct(c, v.escopo)}).` });
      const inf = c.row.dim.Infra.horas, infB = c.row.bdim.Infra.horas;
      if (inf > infB * 1.2) out.push({ cls: "warn", t: "Infra acima do plano", h: `Infra consumiu <b>${inf} h</b> (plano ${infB} h), ainda reflexo do incidente do S09.` });
      return out;
    },
    drillNote: (key) => key === "custoAcum" ? "Orçado acumulado = orçamento total ÷ 16 sprints, linear." : "",
    audit: {
      questions: ["Estamos entregando o que planejamos a cada sprint?", "Quanto do escopo total já foi concluído e quando terminamos no ritmo atual?", "O custo acumulado está dentro do orçado?", "A qualidade (bugs, lead time) está piorando?", "Qual frente consome mais horas e está fora do plano?"],
      gaps: ["Sem story points: entregas contam itens de tamanhos diferentes.", "Bugs sem severidade.", "Custo de pessoas estimado por taxa média por frente."],
      improvements: ["Ponderar entregas por tamanho.", "Separar bugs críticos dos demais.", "Burn-up com escopo que muda ao longo do projeto."],
    },
    insightMetric: "entregas",
    aiContext: "o projeto de software MAE, acompanhado por sprint (entregas, escopo, qualidade, custo e horas por frente)",
  };
})();
