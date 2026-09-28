#!/usr/bin/env python3
"""Gera um painel a partir do motor, trocando só o bloco CONFIG.

Uso:
  python scripts/new_dashboard.py <config.js> <saida.html>
  python scripts/new_dashboard.py --blank <saida.html>   # copia o motor com a config de exemplo

O arquivo de config precisa declarar `const CONFIG = ...;` (veja assets/examples/ops.config.js).
O <title> da página passa a ser o CONFIG.title, que é o que a galeria de artifacts mostra.
"""
import re
import sys
from pathlib import Path

SKILL = Path(__file__).resolve().parent.parent
ENGINE = SKILL / "assets" / "engine" / "dashboard-engine.html"
START = "/* =====================================================================\n   CONFIG START"
END = "/* ============================ CONFIG END ============================ */"


def main(argv):
    if len(argv) == 2 and argv[0] == "--blank":
        cfg_src, out = None, Path(argv[1])
    elif len(argv) == 2:
        cfg_src, out = Path(argv[0]).read_text(encoding="utf-8"), Path(argv[1])
    else:
        print(__doc__)
        return 2

    html = ENGINE.read_text(encoding="utf-8")
    a, b = html.index(START), html.index(END) + len(END)
    if cfg_src is not None:
        if "const CONFIG" not in cfg_src:
            print("erro: o arquivo de config precisa declarar `const CONFIG = ...;`")
            return 1
        html = html[:a] + "/* CONFIG START */\n" + cfg_src.strip() + "\n/* CONFIG END */" + html[b:]

    m = re.search(r'title:\s*"([^"]+)"', html[a:])
    if m:
        html = re.sub(r"<title>[^<]*</title>", f"<title>{m.group(1)}</title>", html, count=1)

    out.write_text(html, encoding="utf-8")
    print(f"ok: {out}  (verifique com: node scripts/check.mjs {out})")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
