// ============================================================================
//  ÓCULOS INTELIGENTES DE IA — GERADOR PARAMÉTRICO DE CHASSI  (Rev B)
//  AI SMART GLASSES — Parametric Chassis Generator
//
//  Armação impressa em 3D com cartuchos eletrônicos removíveis (PETG / FDM).
//  Referência óptica (sistema boxing): 55 [] 18 - 140
//
//  >>> TODAS AS DIMENSÕES SÃO PRELIMINARES (CONCEITO). <<<
//  >>> VALIDAR CONTRA OS COMPONENTES ELETRÔNICOS REAIS ANTES DO CAD FINAL. <<<
//
//  Uso:
//    1. Abra no OpenSCAD (2021.01+ recomendado, com Customizer).
//    2. Escolha a peça em "part" e pressione F5 (preview) / F6 (render).
//    3. Exporte STL (File > Export > Export as STL) por peça.
//    4. Ao medir a armação física de referência, ajuste APENAS o bloco de
//       parâmetros no topo — toda a geometria se regenera.
// ============================================================================

// ------------------------------- QUALIDADE ---------------------------------
$fn = 48;                 // suavidade de arcos (48 preview / 96 para render final)

/* [Peça a gerar] */
// layout = todas as peças espalhadas p/ conferência; demais = 1 STL por peça
part = "layout"; // [layout, front, temple_right, temple_left, cartridge_right, cartridge_left, end_cap]

/* [Referência óptica  —  55 [] 18 - 140] */
lens_w      = 55;   // largura nominal da abertura da lente (spec)
lens_h      = 35;   // altura da lente (CONCEITO — medir armação real)
bridge      = 18;   // ponte, aro a aro (spec)
temple_len  = 140;  // comprimento da haste, dobradiça à ponta (nominal)

/* [Frente] */
rim_t         = 3.5;  // espessura estrutural do aro (rebordo) por lado
rim_radius    = 7;    // raio de canto do aro externo
lens_radius   = 5;    // raio de canto da abertura da lente
front_t       = 4.2;  // espessura (profundidade) da frente  [3.5–5]
brow_h        = 12;   // altura da testeira (barra superior)
hinge_margin  = 5;    // margem estrutural da dobradiça por lado
hinge_stub_h  = 18;   // altura do bloco da dobradiça
hinge_stub_w  = 7;    // largura do bloco da dobradiça

/* [Câmera / óptica  (áreas ajustáveis)] */
camera_d          = 8;   // furo da câmera Ø6–10 (ajustar à câmera real)
camera_window_ext = 1.2; // rebaixo p/ janela transparente vedada
display_bay_w     = 17;  // ÁREA RESERVADA microdisplay (largura) — não é cota fixa
display_bay_h     = 9;   // ÁREA RESERVADA microdisplay (altura)  — não é cota fixa

/* [Hastes — casco] */
temple_w      = 7.5;  // espessura da haste (direção Y)
temple_h      = 9.5;  // altura da haste (direção Z)
temple_edge_r = 1.6;  // raio das arestas do casco
wall          = 1.8;  // espessura de parede  (>= 2x bico 0.4)
bridge_wall   = 4.0;  // reforço estrutural (informativo/echo)

/* [Compartimento (bay) e trilho] */
bay_start   = 6;    // início do compartimento a partir da dobradiça
bay_len     = 78;   // comprimento do compartimento interno
rail_h      = 1.6;  // altura do rasgo/trilho (T-slot simplificado)
rail_d      = 1.2;  // profundidade do rasgo do trilho na parede
cap_depth   = 8;    // profundidade da abertura traseira / encaixe da tampa

/* [Cartucho removível] */
fit_tol      = 0.25; // folga de encaixe por lado (tolerância FDM)
rail_tol     = 0.25; // folga do trilho por lado
cart_front_gap = 3;  // recuo do cartucho na extremidade da dobradiça
latch_w      = 4;    // largura da trava snap
latch_h      = 1.4;  // saliência da trava
conn_w       = 4;    // largura da janela do conector plugável
conn_h       = 5;    // altura da janela do conector

/* [Áudio / acústica] */
spk_chamber_d   = 12;  // diâmetro aproximado da câmara acústica
acoustic_port_d = 1.6; // furo acústico Ø1.5–2.0 (membrana colada por fora)
mic_port_d      = 1.2; // furo do microfone

/* [Vedação — junta de silicone] */
groove_w  = 1.2;  // largura da canaleta da junta
groove_d  = 0.8;  // profundidade da canaleta da junta
cap_flange = 3;   // espessura do flange externo da tampa

// ============================================================================
//  DIMENSÕES DERIVADAS  (memória de cálculo)
// ============================================================================
rim_outer_w = lens_w + 2*rim_t;                 // largura do aro externo (~62)
rim_outer_h = lens_h + 2*rim_t;
front_total_w = 2*rim_outer_w + bridge + 2*hinge_margin; // ~152 (CONCEITO)
front_total_h = rim_outer_h + brow_h;

bay_w = temple_w - 2*wall;                       // largura interna do bay
bay_h = temple_h - 2*wall;                       // altura interna do bay
cart_w = bay_w - 2*fit_tol;
cart_h = bay_h - 2*fit_tol;
cart_len = bay_len - cap_depth - cart_front_gap;

echo("=== ÓCULOS IA — dimensões derivadas (CONCEITO, validar) ===");
echo(front_total_w_mm = front_total_w);
echo(front_total_h_mm = front_total_h);
echo(aro_externo_mm = [rim_outer_w, rim_outer_h]);
echo(bay_interno_mm = [bay_len, bay_w, bay_h]);
echo(cartucho_mm = [cart_len, cart_w, cart_h]);
echo(reforco_ponte_mm = bridge_wall);

// ============================================================================
//  HELPERS 2D / 3D
// ============================================================================
module rrect(w, h, r) {
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(w/2 - r), sy*(h/2 - r)]) circle(r = r);
}

// caixa arredondada com origem no canto (0..l, 0..w, 0..h)
module rbox(l, w, h, r) {
    r2 = min(r, w/2 - 0.01, h/2 - 0.01, l/2 - 0.01);
    translate([r2, r2, r2])
        minkowski() {
            cube([l - 2*r2, w - 2*r2, h - 2*r2]);
            sphere(r = r2, $fn = 24);
        }
}

// ============================================================================
//  01 — FRENTE
// ============================================================================
module lens_ring_2d() {
    difference() {
        rrect(rim_outer_w, rim_outer_h, rim_radius);
        rrect(lens_w, lens_h, lens_radius);
    }
}

module front_profile_2d() {
    cc = rim_outer_w + bridge;      // distância centro-a-centro dos aros
    union() {
        // dois aros
        translate([-cc/2, 0]) lens_ring_2d();
        translate([ cc/2, 0]) lens_ring_2d();
        // ponte (liga a testeira dos dois aros no topo)
        translate([0, rim_outer_h/2 - brow_h/2])
            rrect(bridge + 2*rim_t, brow_h, 2);
        // testeira (barra superior contínua)
        translate([0, rim_outer_h/2 + brow_h/2 - 1])
            rrect(2*rim_outer_w + bridge, brow_h, 3);
        // blocos de dobradiça nas extremidades
        for (sx = [-1, 1])
            translate([sx*(cc/2 + rim_outer_w/2 + hinge_stub_w/2 - 1), 0])
                rrect(hinge_stub_w + 2, hinge_stub_h, 1.5);
    }
}

module front() {
    cc = rim_outer_w + bridge;
    difference() {
        linear_extrude(height = front_t) front_profile_2d();

        // furo da câmera (acima da ponte, centralizado)
        translate([0, rim_outer_h/2 + brow_h/2 - 1, -1])
            cylinder(h = front_t + 2, d = camera_d);
        // rebaixo p/ janela transparente vedada da câmera
        translate([0, rim_outer_h/2 + brow_h/2 - 1, front_t - camera_window_ext])
            cylinder(h = camera_window_ext + 1, d = camera_d + 2*1.5);

        // ÁREA RESERVADA do microdisplay (bolsão raso, lente direita, topo interno)
        translate([cc/2 - lens_w/2 + display_bay_w/2,
                   rim_outer_h/2 - rim_t - display_bay_h/2,
                   front_t - 2.5])
            cube([display_bay_w, display_bay_h, 3], center = true);
    }
}

// ============================================================================
//  02 — HASTE (casco)  |  elec=true -> direita (ESP32/4G/mic)
//                       |  elec=false -> esquerda (bateria/áudio)
// ============================================================================
module rail_female() {
    // rasgos cavados PARA DENTRO das duas paredes laterais, ao longo do bay
    // (deixa ~0.6 mm de parede; a nervura macho do cartucho corre aqui)
    for (sy = [-1, 1])
        translate([bay_start,
                   sy < 0 ? -bay_w/2 - rail_d : bay_w/2,
                   wall + bay_h/2 - rail_h/2])
            cube([bay_len - cap_depth, rail_d, rail_h]);
}

module temple(elec = true) {
    difference() {
        // casco externo, centrado em Y, base em Z=0
        translate([0, -temple_w/2, 0]) rbox(temple_len, temple_w, temple_h, temple_edge_r);

        // compartimento interno (bay)
        translate([bay_start, -bay_w/2, wall])
            cube([bay_len - cap_depth, bay_w, bay_h]);

        // abertura traseira (encaixe da tampa / entrada do cartucho)
        translate([bay_start + bay_len - cap_depth, -bay_w/2, wall])
            cube([cap_depth + 1, bay_w, bay_h]);

        // rasgos do trilho (fêmea)
        rail_female();

        // janela do conector plugável (extremidade da dobradiça)
        translate([bay_start - 0.5, -conn_w/2, wall + bay_h/2 - conn_h/2])
            cube([wall + 1, conn_w, conn_h]);

        if (elec) {
            // furo do microfone (face inferior, próximo à frente)
            translate([bay_start + 8, 0, -1])
                cylinder(h = wall + 2, d = mic_port_d);
        } else {
            // furos acústicos do alto-falante (atravessam a espessura Y,
            // próximo à orelha; membrana hidrofóbica colada por fora)
            for (i = [0, 1])
                translate([temple_len - 22 + i*6, 0, temple_h/2])
                    rotate([90, 0, 0])
                        cylinder(h = temple_w + 2, d = acoustic_port_d, center = true);
        }
    }

    // câmara acústica (parede interna que isola o alto-falante) — só haste esq.
    if (!elec) {
        translate([temple_len - 26, -bay_w/2, wall])
            cube([1.6, bay_w, bay_h]);   // divisória de isolamento
    }
}

// ============================================================================
//  08 — CARTUCHO REMOVÍVEL  (desliza no trilho + trava snap + conector)
// ============================================================================
module rail_male() {
    for (sy = [-1, 1])
        translate([0,
                   sy*(cart_w/2) + (sy < 0 ? -(rail_d - rail_tol) : 0),
                   cart_h/2 - rail_h/2])
            cube([cart_len, rail_d - rail_tol, rail_h - 2*rail_tol]);
}

module cartridge(elec = true) {
    difference() {
        union() {
            // corpo do cartucho
            translate([0, -cart_w/2, 0]) rbox(cart_len, cart_w, cart_h, 1);
            // ribs do trilho (macho)
            translate([0, 0, 0]) rail_male();
            // trava snap (saliência na extremidade traseira)
            translate([cart_len - latch_w, -cart_w/2, cart_h])
                cube([latch_w, cart_w, latch_h]);
        }
        // bolsão da eletrônica (VOLUME RESERVADO — visual, não cota fixa)
        translate([4, -cart_w/2 + 1.2, 1.2])
            cube([cart_len - 8, cart_w - 2.4, cart_h - 2.4]);
        // recorte do conector plugável (extremidade da dobradiça)
        translate([-1, -conn_w/2, cart_h/2 - conn_h/2])
            cube([conn_w, conn_w, conn_h]);
    }
    // marcação da carga: R (elec) ou L
    // (etiqueta apenas para orientação de montagem)
}

// ============================================================================
//  10 — TAMPA COM CANALETA DE VEDAÇÃO  (junta de silicone comprimida)
// ============================================================================
// anel retangular subtraído ao redor do plugue -> canaleta da junta
module cap_gasket_groove(plug_w, plug_h) {
    difference() {
        cube([groove_w, plug_w + 2, plug_h + 2], center = true);
        cube([groove_w + 2, plug_w + 2 - 2*groove_d, plug_h + 2 - 2*groove_d], center = true);
    }
}

module end_cap() {
    plug_w = bay_w - 2*fit_tol;
    plug_h = bay_h - 2*fit_tol;
    zc = wall + fit_tol + plug_h/2;
    difference() {
        union() {
            // flange externo (batente contra o casco)
            translate([0, -temple_w/2, 0]) rbox(cap_flange, temple_w, temple_h, temple_edge_r);
            // plugue que entra na abertura
            translate([cap_flange, -plug_w/2, wall + fit_tol])
                cube([cap_depth - fit_tol, plug_w, plug_h]);
        }
        // canaleta da junta (anel fechado e simétrico ao redor do plugue)
        translate([cap_flange + 2, 0, zc]) cap_gasket_groove(plug_w, plug_h);
    }
}

// ============================================================================
//  LAYOUT DE CONFERÊNCIA  (todas as peças espalhadas)
// ============================================================================
module layout() {
    front();
    translate([0, -60, 0]) temple(elec = true);
    translate([0, -80, 0]) cartridge(elec = true);
    translate([0, -100, 0]) mirror([0, 1, 0]) temple(elec = false);
    translate([0, -120, 0]) cartridge(elec = false);
    translate([0, -140, 0]) end_cap();
}

// ============================================================================
//  SELETOR
// ============================================================================
if      (part == "front")          front();
else if (part == "temple_right")   temple(elec = true);
else if (part == "temple_left")    mirror([0, 1, 0]) temple(elec = false);
else if (part == "cartridge_right") cartridge(elec = true);
else if (part == "cartridge_left")  cartridge(elec = false);
else if (part == "end_cap")        end_cap();
else                               layout();
