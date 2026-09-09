#!/usr/bin/env python3
"""
update_scad.py — fecha o loop "medir -> regenerar" do gerador de óculos IA.

Lê um CSV com as dimensões REAIS dos componentes eletrônicos, calcula os
compartimentos (bays), a seção das hastes, a folga de tolerância e o furo da
câmera, e reescreve os parâmetros nomeados no ai_glasses.scad — sem tocar na
geometria. Depois é só reabrir no OpenSCAD e regenerar os STLs.

Uso:
    python3 update_scad.py --components components.csv --scad ai_glasses.scad --in-place
    python3 update_scad.py --components components.csv --scad ai_glasses.scad --out ai_glasses.gen.scad
    python3 update_scad.py --print-template > components.csv     # gera CSV de exemplo
    python3 update_scad.py --components components.csv --dry-run  # só mostra o cálculo

CSV esperado (cabeçalho obrigatório):
    component,side,length_mm,width_mm,height_mm,clearance_mm,notes

    side        : right | left | front   (right/left = hastes; front = frente)
    length_mm   : dimensão ao longo da haste (empilhamento)
    width_mm    : dimensão na espessura da haste (Y)
    height_mm   : dimensão na altura da haste (Z)
    clearance_mm: folga desejada em volta do componente (padrão via --clearance)

    Componentes especiais (por nome, case-insensitive):
      contém "camera"                 -> define camera_d (usa maior de W/H)
      contém "display" ou "combiner"  -> define display_bay_w/h

Somente stdlib. Sem dependências externas.
"""
from __future__ import annotations
import argparse
import csv
import re
import sys
from dataclasses import dataclass, field
from io import StringIO

# --------------------------------------------------------------------------- #
#  Modelo de dados
# --------------------------------------------------------------------------- #
@dataclass
class Component:
    name: str
    side: str
    length: float
    width: float
    height: float
    clearance: float
    notes: str = ""


@dataclass
class SideResult:
    bay_len: float = 0.0
    bay_w: float = 0.0
    bay_h: float = 0.0
    items: list[str] = field(default_factory=list)


TEMPLATE_CSV = """component,side,length_mm,width_mm,height_mm,clearance_mm,notes
ESP32-S3,right,25.5,18.0,3.5,0.8,placa principal
A7670SA 4G,right,24.0,17.6,2.4,0.8,modem LTE
MIC MEMS,right,4.0,3.0,1.0,0.5,microfone
Camera OV2640,front,9.0,9.0,6.0,0.6,câmera frontal (define furo)
Microdisplay,front,12.0,10.0,4.0,0.8,area reservada do display
Bateria LiPo,left,50.0,20.0,6.0,1.0,bateria recarregavel
PMIC,left,10.0,10.0,2.0,0.6,gerenciamento de energia
MAX98357A,left,16.0,12.0,2.5,0.6,amplificador I2S
Speaker,left,12.0,12.0,4.0,0.8,microalto-falante
"""

# Parâmetros do .scad que este script controla (os demais ficam intactos).
CONTROLLED = ["temple_w", "temple_h", "bay_len", "wall", "fit_tol",
              "camera_d", "display_bay_w", "display_bay_h"]


# --------------------------------------------------------------------------- #
#  Leitura do CSV
# --------------------------------------------------------------------------- #
def load_components(path: str, default_clearance: float) -> list[Component]:
    with open(path, newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        required = {"component", "side", "length_mm", "width_mm", "height_mm"}
        missing = required - set(h.strip() for h in (reader.fieldnames or []))
        if missing:
            sys.exit(f"[erro] colunas ausentes no CSV: {', '.join(sorted(missing))}")

        out: list[Component] = []
        for i, row in enumerate(reader, start=2):
            side = (row.get("side") or "").strip().lower()
            if side not in {"right", "left", "front"}:
                sys.exit(f"[erro] linha {i}: side inválido '{side}' "
                         f"(use right | left | front)")
            try:
                clr_raw = (row.get("clearance_mm") or "").strip()
                out.append(Component(
                    name=row["component"].strip(),
                    side=side,
                    length=float(row["length_mm"]),
                    width=float(row["width_mm"]),
                    height=float(row["height_mm"]),
                    clearance=float(clr_raw) if clr_raw else default_clearance,
                    notes=(row.get("notes") or "").strip(),
                ))
            except ValueError as e:
                sys.exit(f"[erro] linha {i}: valor numérico inválido ({e})")
        if not out:
            sys.exit("[erro] CSV sem componentes.")
        return out


# --------------------------------------------------------------------------- #
#  Cálculo de dimensões
# --------------------------------------------------------------------------- #
def compute(components: list[Component], wall: float, gap: float) -> dict:
    sides: dict[str, SideResult] = {"right": SideResult(), "left": SideResult()}
    camera_d = None
    display_w = display_h = None

    for c in components:
        nl = c.name.lower()
        if "camera" in nl:
            camera_d = max(camera_d or 0, max(c.width, c.height) + 2 * c.clearance)
        if "display" in nl or "combiner" in nl:
            display_w = max(display_w or 0, c.width + 2 * c.clearance)
            display_h = max(display_h or 0, c.height + 2 * c.clearance)
        if c.side in sides:
            s = sides[c.side]
            s.bay_len += c.length + gap
            s.bay_w = max(s.bay_w, c.width + 2 * c.clearance)
            s.bay_h = max(s.bay_h, c.height + 2 * c.clearance)
            s.items.append(c.name)

    # a armação usa uma única seção de haste -> pega o envelope máximo dos dois lados
    bay_w = max(sides["right"].bay_w, sides["left"].bay_w)
    bay_h = max(sides["right"].bay_h, sides["left"].bay_h)
    bay_len = max(sides["right"].bay_len, sides["left"].bay_len)

    result = {
        "sides": sides,
        "bay_w": r1(bay_w),
        "bay_h": r1(bay_h),
        "bay_len": r1(bay_len),
        "temple_w": r1(bay_w + 2 * wall),
        "temple_h": r1(bay_h + 2 * wall),
        "wall": r1(wall),
    }
    if camera_d:
        result["camera_d"] = r1(camera_d)
    if display_w:
        result["display_bay_w"] = r1(display_w)
        result["display_bay_h"] = r1(display_h)
    return result


def r1(x: float) -> float:
    return round(x + 1e-9, 1)


# --------------------------------------------------------------------------- #
#  Patch do .scad  (substitui só o valor entre '=' e ';', preserva comentário)
# --------------------------------------------------------------------------- #
def patch_scad(text: str, values: dict) -> tuple[str, list[str]]:
    changed: list[str] = []
    for name, val in values.items():
        if name not in CONTROLLED:
            continue
        num = fmt_num(val)
        pattern = re.compile(rf"(?m)^(\s*{re.escape(name)}\s*=\s*)([^;]*?)(\s*;)")
        new_text, n = pattern.subn(
            lambda m, num=num: f"{m.group(1)}{num}{m.group(3)}", text)
        if n == 0:
            changed.append(f"  ! {name}: não encontrado no .scad (ignorado)")
        else:
            changed.append(f"  ✓ {name} = {num}")
            text = new_text
    return text, changed


def fmt_num(x: float) -> str:
    return str(int(x)) if float(x).is_integer() else f"{x:g}"


# --------------------------------------------------------------------------- #
#  Relatório
# --------------------------------------------------------------------------- #
def report(values: dict, wall: float) -> None:
    sides = values["sides"]
    print("── Cálculo por lado (CONCEITO, validar) ──────────────────────")
    for side in ("right", "left"):
        s = sides[side]
        label = "haste DIREITA" if side == "right" else "haste ESQUERDA"
        print(f"  {label:16s} bay ≈ {s.bay_len:6.1f} × {s.bay_w:4.1f} × {s.bay_h:4.1f} mm"
              f"   [{', '.join(s.items) or '—'}]")
    print("── Envelope aplicado ao .scad ────────────────────────────────")
    print(f"  bay_len   = {values['bay_len']:>6} mm  (maior dos dois lados)")
    print(f"  temple_w  = {values['temple_w']:>6} mm  (= bay_w {values['bay_w']} + 2×wall {wall})")
    print(f"  temple_h  = {values['temple_h']:>6} mm  (= bay_h {values['bay_h']} + 2×wall {wall})")
    if "camera_d" in values:
        print(f"  camera_d  = {values['camera_d']:>6} mm")
    if "display_bay_w" in values:
        print(f"  display   = {values['display_bay_w']} × {values['display_bay_h']} mm")
    print("──────────────────────────────────────────────────────────────")


# --------------------------------------------------------------------------- #
#  Sanidade
# --------------------------------------------------------------------------- #
def sanity_warnings(values: dict, wall: float) -> list[str]:
    warns = []
    if wall < 0.8:
        warns.append(f"parede {wall} mm < 0.8 mm (frágil em FDM)")
    if values["temple_h"] > 22:
        warns.append(f"temple_h {values['temple_h']} mm — haste muito alta, "
                     "reveja empilhamento/orientação dos componentes")
    if values["bay_len"] > 120:
        warns.append(f"bay_len {values['bay_len']} mm pode exceder o comprimento útil "
                     "da haste (temple_straight) — ajuste no .scad")
    return warns


# --------------------------------------------------------------------------- #
#  CLI
# --------------------------------------------------------------------------- #
def main() -> None:
    ap = argparse.ArgumentParser(description="Atualiza parâmetros do ai_glasses.scad a partir de um CSV de componentes.")
    ap.add_argument("--components", help="CSV de componentes")
    ap.add_argument("--scad", help="arquivo .scad a atualizar")
    ap.add_argument("--out", help="escreve o resultado neste arquivo (senão usa --in-place ou stdout)")
    ap.add_argument("--in-place", action="store_true", help="reescreve o próprio .scad")
    ap.add_argument("--wall", type=float, default=1.8, help="espessura de parede (mm) [1.8]")
    ap.add_argument("--clearance", type=float, default=0.6, help="folga padrão por componente (mm) [0.6]")
    ap.add_argument("--gap", type=float, default=3.0, help="folga entre componentes empilhados (mm) [3.0]")
    ap.add_argument("--dry-run", action="store_true", help="só calcula e mostra, não grava")
    ap.add_argument("--print-template", action="store_true", help="imprime um components.csv de exemplo e sai")
    args = ap.parse_args()

    if args.print_template:
        sys.stdout.write(TEMPLATE_CSV)
        return

    if not args.components:
        ap.error("--components é obrigatório (ou use --print-template)")

    components = load_components(args.components, args.clearance)
    values = compute(components, wall=args.wall, gap=args.gap)

    report(values, args.wall)
    for w in sanity_warnings(values, args.wall):
        print(f"[aviso] {w}", file=sys.stderr)

    if args.dry_run:
        return

    if not args.scad:
        ap.error("--scad é obrigatório para gravar (ou use --dry-run)")

    with open(args.scad, encoding="utf-8") as fh:
        text = fh.read()

    new_text, changes = patch_scad(text, values)
    print("── Parâmetros escritos ───────────────────────────────────────")
    for c in changes:
        print(c)

    if args.in_place:
        with open(args.scad, "w", encoding="utf-8") as fh:
            fh.write(new_text)
        print(f"[ok] {args.scad} atualizado in-place.")
    elif args.out:
        with open(args.out, "w", encoding="utf-8") as fh:
            fh.write(new_text)
        print(f"[ok] escrito em {args.out}.")
    else:
        sys.stdout.write(new_text)


if __name__ == "__main__":
    main()
