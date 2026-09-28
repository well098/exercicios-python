// Exemplo fora de finanças: operação de uma plataforma (produto + suporte).
// Gere o painel com:  python scripts/new_dashboard.py assets/examples/ops.config.js painel-ops.html
const CONFIG = (() => {
  const CANAIS = ["Chat", "E-mail", "Telefone"];
  const rows = [];
  for (let i = 0; i < 18; i++) {
    const d = new Date(2025, 3 + i, 1);
    const p = d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0");
    const usuarios = Math.round(18000 * Math.pow(1.045, i) * (1 + 0.02 * Math.sin(i * 1.3)));
    const incidente = i === 13; // mês com incidente de infraestrutura
    const base = usuarios / 1000;
    const dim = {
      "Chat":     { tickets: Math.round(base * 22 * (incidente ? 1.8 : 1)), tempoResposta: 6 + 2 * Math.sin(i) + (incidente ? 9 : 0) },
      "E-mail":   { tickets: Math.round(base * 14 * (incidente ? 1.5 : 1)), tempoResposta: 95 - i * 2.2 + (incidente ? 60 : 0) },
      "Telefone": { tickets: Math.round(base * 6 * (incidente ? 2.2 : 1)),  tempoResposta: 3 + Math.cos(i) },
    };
    const tickets = CANAIS.reduce((s, k) => s + dim[k].tickets, 0);
    const tempoResposta = CANAIS.reduce((s, k) => s + dim[k].tickets * dim[k].tempoResposta, 0) / tickets;
    const v = {
      usuarios,
      cadastros: Math.round(usuarios * 0.085 * (1 + 0.1 * Math.sin(i * 0.8))),
      tickets,
      tempoResposta,
      sla: Math.min(0.995, 0.9 + i * 0.004 - (incidente ? 0.11 : 0) + 0.01 * Math.sin(i)),
      nps: 42 + i * 0.9 - (incidente ? 14 : 0) + 2 * Math.sin(i * 1.7),
      uptime: incidente ? 0.9921 : 0.9985 + 0.0008 * Math.sin(i),
      custoInfra: Math.round(38000 * Math.pow(1.03, i) * (incidente ? 1.25 : 1)),
      custoSuporte: Math.round(tickets * 11.5),
    };
    const b = { tickets: Math.round(base * 40), tempoResposta: 30, sla: 0.95, nps: 50, uptime: 0.999, custoInfra: Math.round(39000 * Math.pow(1.028, i)), custoSuporte: Math.round(base * 40 * 11) };
    const bdim = { "Chat": { tickets: Math.round(base * 21) }, "E-mail": { tickets: Math.round(base * 13) }, "Telefone": { tickets: Math.round(base * 6) } };
    rows.push({ p, v, b, dim, bdim });
  }
  return {
    title: "Central de Operações",
    eyebrow: "Plataforma · produto & suporte",
    subtitle: "Saúde da operação mês a mês. Clique em qualquer indicador ou canal para abrir o histórico.",
    footnote: "Dados de exemplo de uma plataforma com suporte em três canais.",
    palette: "menta",
    currency: "BRL",
    periodType: "month",
    yearLag: 12,
    budgetLabel: "Meta",
    metrics: {
      usuarios:       { label: "Usuários ativos",        unit: "number",   dir: 1, noBudget: true },
      cadastros:      { label: "Novos cadastros",        unit: "number",   dir: 1, noBudget: true },
      tickets:        { label: "Tickets de suporte",     unit: "number",   dir: -1 },
      ticketsPorMil:  { label: "Tickets por mil usuários", unit: "number", dir: -1 },
      tempoResposta:  { label: "Tempo médio de resposta", unit: "minutes", dir: -1 },
      sla:            { label: "SLA cumprido",           unit: "percent",  dir: 1 },
      nps:            { label: "NPS",                    unit: "score",    dir: 1 },
      uptime:         { label: "Uptime",                 unit: "percent",  dir: 1, decimals: 2 },
      custoInfra:     { label: "Custo de infraestrutura", unit: "currency", dir: -1 },
      custoSuporte:   { label: "Custo de suporte",       unit: "currency", dir: -1 },
      custoTotal:     { label: "Custo total da operação", unit: "currency", dir: -1 },
      custoPorUsuario:{ label: "Custo por usuário",      unit: "currency", dir: -1, noBudget: true },
    },
    derive: (x) => {
      if (x.custoInfra != null && x.custoSuporte != null) x.custoTotal = x.custoInfra + x.custoSuporte;
      if (x.usuarios) { x.ticketsPorMil = x.tickets / (x.usuarios / 1000); if (x.custoTotal != null) x.custoPorUsuario = x.custoTotal / x.usuarios; }
      return x;
    },
    rows,
    tiers: {
      labels: ["1 · Crescimento & experiência", "2 · Qualidade do suporte", "3 · Eficiência"],
      t1: [{ key: "usuarios" }, { key: "nps" }, { key: "uptime", style: "alt", title: "Disponibilidade" }],
      t2: ["sla", "tempoResposta", "tickets", "custoTotal"],
    },
    tileFoot: (key, c) => {
      const v = c.row.v;
      if (key === "usuarios") return `${c.fmt("number", v.cadastros, true)} novos cadastros no mês`;
      if (key === "nps") return `meta ${c.num(c.row.b.nps, 0)}`;
      if (key === "uptime") { const min = (1 - v.uptime) * 30 * 24 * 60; return `≈ <b>${c.num(min, 0)} min</b> fora do ar no mês · meta ${c.fmt("percent", c.row.b.uptime, false, 1)}`; }
      return "";
    },
    ratios: (c) => {
      const v = c.row.v, y = c.yoyRow, p = c.prevRow;
      const cresc = p ? (v.usuarios - p.v.usuarios) / p.v.usuarios : null;
      return [
        { label: "Crescimento de usuários (mês)", value: cresc == null ? "—" : c.signed(cresc * 100, 1) + "%", note: p ? `${c.fmt("number", p.v.usuarios, true)} → ${c.fmt("number", v.usuarios, true)}` : "", status: cresc == null ? "" : cresc >= 0.03 ? "good" : cresc >= 0 ? "warn" : "bad" },
        { label: "Tickets por mil usuários", value: c.num(v.ticketsPorMil, 1), note: "quanto menor, mais autoatendimento funciona", status: v.ticketsPorMil <= 40 ? "good" : v.ticketsPorMil <= 50 ? "warn" : "bad" },
        { label: "Custo por usuário", value: "R$ " + c.num(v.custoPorUsuario, 2), note: y ? `era R$ ${c.num(y.v.custoPorUsuario, 2)} há 12 meses` : "infra + suporte ÷ usuários", status: y ? (v.custoPorUsuario < y.v.custoPorUsuario ? "good" : "bad") : "" },
        { label: "Minutos fora do ar", value: c.num((1 - v.uptime) * 43200, 0) + " min", note: `meta: até ${c.num((1 - c.row.b.uptime) * 43200, 0)} min/mês`, status: v.uptime >= c.row.b.uptime ? "good" : "bad" },
      ];
    },
    table: [
      { key: "usuarios", style: "total" }, { key: "cadastros", style: "sub" },
      { key: "tickets", style: "total" }, { key: "ticketsPorMil", style: "sub" }, { key: "tempoResposta", style: "sub" }, { key: "sla", style: "sub" },
      { key: "nps", style: "total" }, { key: "uptime", style: "total" },
      { key: "custoTotal", style: "total" }, { key: "custoInfra", style: "sub" }, { key: "custoSuporte", style: "sub" },
    ],
    bridge: { title: "Ponte do custo da operação", target: "custoTotal", parts: [
      { key: "custoInfra", sign: 1, label: "Infra" }, { key: "custoSuporte", sign: 1, label: "Suporte" } ] },
    trend: { title: "Tickets de suporte: tendência e projeção", series: ["tickets"], horizon: 6 },
    breakdown: { title: "Tickets por canal", dimension: "canal", metric: "tickets", secondary: "tempoResposta", secondaryLabel: "resposta média",
      members: [{ k: "Chat", color: "--c1" }, { k: "E-mail", color: "--c2" }, { k: "Telefone", color: "--c3" }] },
    attention: (c) => {
      const v = c.row.v, b = c.row.b;
      if (v.uptime < b.uptime) return { t: `Uptime ${c.fmt("percent", v.uptime, false, 2)}`, b: `Abaixo da meta de ${c.fmt("percent", b.uptime, false, 1)}: cerca de ${c.num((1 - v.uptime) * 43200, 0)} minutos fora do ar no mês.` };
      if (v.sla < b.sla) return { t: `SLA ${c.fmt("percent", v.sla)}`, b: `Abaixo da meta de ${c.fmt("percent", b.sla)}.` };
      return null;
    },
    audit: {
      questions: ["A base de usuários está crescendo e em que ritmo?", "O suporte acompanha o crescimento sem estourar SLA e tempo de resposta?", "Qual canal concentra volume e qual responde mais devagar?", "A plataforma ficou fora do ar além da meta?", "O custo por usuário está caindo com a escala?"],
      gaps: ["Sem dados de causa dos tickets (categoria/produto).", "NPS mensal sem número de respostas (confiança da amostra).", "Custo de suporte estimado por ticket, não por hora trabalhada."],
      improvements: ["Classificar tickets por causa para atacar a raiz do volume.", "Ligar incidentes de uptime aos picos de tickets automaticamente.", "Alertas quando SLA ou uptime ficarem abaixo da meta."],
    },
    aiContext: "a operação de uma plataforma digital (produto e suporte)",
  };
})();
