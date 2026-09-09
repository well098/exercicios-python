// ============================================================================
//  ÓCULOS INTELIGENTES DE IA — GERADOR PARAMÉTRICO DE CHASSI  (Rev C — elegante)
//  AI SMART GLASSES — Parametric Chassis Generator
//
//  Armação impressa em 3D com cartuchos eletrônicos removíveis (PETG / FDM).
//  Referência óptica (sistema boxing): 55 [] 18 - 140
//
//  Rev C: hastes afiladas com gancho de orelha curvo e seção cápsula,
//         ponte curvada, apoios de nariz, boss da câmera, cartuchos
//         arredondados com pega. Toda a geometria segue paramétrica.
//
//  >>> TODAS AS DIMENSÕES SÃO PRELIMINARES (CONCEITO). <<<
//  >>> VALIDAR CONTRA OS COMPONENTES ELETRÔNICOS REAIS ANTES DO CAD FINAL. <<<
//
//  Uso:
//    1. Abra no OpenSCAD (2021.01+), painel Customizer à direita.
//    2. Escolha a peça em "part" -> F5 (preview) / F6 (render) / F7 (export STL).
//    3. Ao medir a armação física, ajuste APENAS o bloco de parâmetros no topo.
// ============================================================================

// ------------------------------- QUALIDADE ---------------------------------
$fn = 64;                 // 64 preview / 96–128 para render final

/* [Peça a gerar] */
part = "layout"; // [layout, front, temple_right, temple_left, cartridge_right, cartridge_left, end_cap]

/* [Referência óptica  —  55 [] 18 - 140] */
lens_w      = 55;   // largura nominal da abertura da lente (spec)
lens_h      = 36;   // altura da lente (CONCEITO — medir armação real)
bridge      = 18;   // ponte, aro a aro (spec)
temple_len  = 140;  // comprimento total da haste, dobradiça à ponta

/* [Frente — estilo] */
rim_t         = 3.0;  // espessura do aro (rebordo) por lado — fino = elegante
rim_radius    = 12;   // raio de canto externo do aro (bem suave)
lens_radius   = 10;   // raio de canto da abertura da lente
front_t       = 4.2;  // espessura (profundidade) da frente  [3.5–5]
front_bevel   = 1.2;  // bisel da face frontal (visual de armação real)
hinge_margin  = 5;    // margem estrutural da dobradiça por lado
hinge_pad_h   = 14;   // altura da pequena aba da dobradiça (integrada)
hinge_pad_w   = 5;    // largura da aba da dobradiça
bridge_bar_h  = 5;    // altura da ponte (barra delicada)
bridge_dip    = 4;    // rebaixo curvo da ponte (keyhole)

/* [Nariz] */
nose_pad_w    = 4.5;  // largura do apoio de nariz
nose_pad_h    = 8;    // altura do apoio de nariz
nose_pad_ang  = 22;   // abertura dos apoios (graus)

/* [Câmera  (canto superior externo — NÃO no meio)] */
camera_side       = 1;   // 1 = lente direita, -1 = lente esquerda
camera_d          = 8;   // furo da câmera Ø6–10 (ajustar à câmera real)
camera_pod_d      = 12;  // diâmetro do pod (ressalto) da câmera
camera_pod_h      = 2.2; // altura do pod
camera_edge_inset = 8;   // recuo a partir do canto do aro
camera_window_ext = 1.2; // rebaixo p/ janela transparente vedada
display_bay_w     = 17;  // ÁREA RESERVADA microdisplay (largura) — não é cota fixa
display_bay_h     = 9;   // ÁREA RESERVADA microdisplay (altura)  — não é cota fixa

/* [Hastes — forma] */
temple_w        = 8.0;  // espessura da haste na dobradiça (direção Y)
temple_h        = 10.5; // altura da haste na dobradiça (direção Z)
temple_straight = 96;   // comprimento da seção reta (eletrônica)
taper_end       = 0.80; // afilamento no fim da seção reta (fração)
tip_scale       = 0.55; // afilamento na ponta do gancho (fração)
ear_hook_radius = 26;   // raio do gancho de orelha
ear_hook_angle  = 78;   // varredura do gancho (graus)
wall            = 1.8;  // espessura de parede  (>= 2x bico 0.4)
bridge_wall     = 4.0;  // reforço estrutural (informativo/echo)

/* [Compartimento (bay) e trilho] */
bay_start   = 6;    // início do compartimento a partir da dobradiça
bay_len     = 78;   // comprimento do compartimento interno
rail_h      = 1.6;  // altura do rasgo/trilho
rail_d      = 1.2;  // profundidade do rasgo do trilho na parede
cap_depth   = 8;    // profundidade da abertura traseira / encaixe da tampa

/* [Cartucho removível] */
fit_tol       = 0.25; // folga de encaixe por lado (tolerância FDM)
rail_tol      = 0.25; // folga do trilho por lado
cart_front_gap = 3;   // recuo do cartucho na extremidade da dobradiça
cart_taper    = 0.92; // leve afilamento do cartucho (elegância + saque)
grip_ridges   = 3;    // ranhuras de pega na tampa traseira do cartucho
latch_w       = 4;    // largura da trava snap
latch_h       = 1.4;  // saliência da trava
conn_w        = 4;    // largura da janela do conector plugável
conn_h        = 5;    // altura da janela do conector

/* [Áudio / acústica] */
acoustic_port_d = 1.6; // furo acústico Ø1.5–2.0 (membrana colada por fora)
mic_port_d      = 1.2; // furo do microfone
spk_divider_t   = 1.6; // divisória de isolamento da câmara acústica

/* [Vedação — junta de silicone] */
groove_w   = 1.2;  // largura da canaleta da junta
groove_d   = 0.8;  // profundidade da canaleta da junta
cap_flange = 3;    // espessura do flange externo da tampa

// ============================================================================
//  DIMENSÕES DERIVADAS  (memória de cálculo)
// ============================================================================
rim_outer_w   = lens_w + 2*rim_t;
rim_outer_h   = lens_h + 2*rim_t;
front_total_w = 2*rim_outer_w + bridge + 2*hinge_margin;   // ~150 (CONCEITO)
front_total_h = rim_outer_h;
zc            = temple_h/2;                                 // eixo neutro da haste
bay_w         = temple_w - 2*wall;
bay_h         = temple_h - 2*wall;
cart_w        = bay_w - 2*fit_tol;
cart_h        = bay_h - 2*fit_tol;
cart_len      = bay_len - cap_depth - cart_front_gap;
cc_front      = rim_outer_w + bridge;                       // centro-a-centro dos aros
cam_cx        = camera_side*(cc_front/2 + rim_outer_w/2 - camera_edge_inset);
cam_cy        = rim_outer_h/2 - camera_edge_inset*0.5;      // canto superior do aro

echo("=== ÓCULOS IA (Rev C) — dimensões derivadas (CONCEITO, validar) ===");
echo(front_total_w_mm = front_total_w);
echo(front_total_h_mm = front_total_h);
echo(aro_externo_mm = [rim_outer_w, rim_outer_h]);
echo(bay_interno_mm = [bay_len, bay_w, bay_h]);
echo(cartucho_mm = [cart_len, cart_w, cart_h]);

// ============================================================================
//  HELPERS
// ============================================================================
module rrect(w, h, r) {
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(w/2 - r), sy*(h/2 - r)]) circle(r = r);
}

// caixa arredondada, origem no canto (0..l, 0..w, 0..h)
module rbox(l, w, h, r) {
    r2 = min(r, w/2 - 0.01, h/2 - 0.01, l/2 - 0.01);
    translate([r2, r2, r2]) minkowski() {
        cube([l - 2*r2, w - 2*r2, h - 2*r2]);
        sphere(r = r2, $fn = 24);
    }
}

// caixa arredondada centrada
module rbox_c(l, w, h, r) {
    r2 = min(r, l/2 - 0.01, w/2 - 0.01, h/2 - 0.01);
    minkowski() {
        cube([l - 2*r2, w - 2*r2, h - 2*r2], center = true);
        sphere(r = r2, $fn = 20);
    }
}

// seção transversal fina tipo "cápsula" (fina em X, w×h em Y×Z), escala s
slab_t = 0.9;
module capsule_xsec(s) {
    rbox_c(slab_t, temple_w*s, temple_h*s, min(temple_w, temple_h)/2*s);
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
    union() {
        // dois aros finos
        translate([-cc_front/2, 0]) lens_ring_2d();
        translate([ cc_front/2, 0]) lens_ring_2d();
        // ponte dupla delicada (estilo elegante, conecta os aros claramente)
        for (yy = [rim_outer_h/2 - 3, rim_outer_h/2 - 3 - bridge_bar_h])
            translate([0, yy]) rrect(bridge + 2*rim_t + 8, 2.6, 1.3);
        // abas de dobradiça pequenas e integradas (protrusão mínima)
        for (sx = [-1, 1])
            translate([sx*(cc_front/2 + rim_outer_w/2 + hinge_pad_w/2 - 2), 0])
                rrect(hinge_pad_w + 2, hinge_pad_h, hinge_pad_w/2);
    }
}

module nose_pad(sx) {
    translate([sx*(bridge/2 + 0.5), -rim_outer_h/2 + nose_pad_h/2 + 1, front_t/2])
        rotate([0, 0, sx*nose_pad_ang])
            rbox_c(front_t + 1.5, nose_pad_w, nose_pad_h, 2);
}

// bisel da borda frontal de cada lente (abertura que alarga em direção à face)
module lens_chamfer(sx) {
    translate([sx*cc_front/2, 0, front_t - front_bevel])
        linear_extrude(height = front_bevel + 0.1, scale = 1.16)
            rrect(lens_w, lens_h, lens_radius);
}

module front() {
    difference() {
        union() {
            linear_extrude(height = front_t) front_profile_2d();
            // pod da câmera no canto superior externo (NÃO no meio)
            translate([cam_cx, cam_cy, front_t - 0.1]) cylinder(h = camera_pod_h, d = camera_pod_d);
            nose_pad(-1);
            nose_pad( 1);
        }
        // bisel elegante nas aberturas das lentes
        lens_chamfer(-1);
        lens_chamfer( 1);
        // furo da câmera (através do pod)
        translate([cam_cx, cam_cy, -1]) cylinder(h = front_t + camera_pod_h + 2, d = camera_d);
        // rebaixo p/ janela vedada
        translate([cam_cx, cam_cy, front_t + camera_pod_h - camera_window_ext])
            cylinder(h = camera_window_ext + 1, d = camera_d + 3);
        // ÁREA RESERVADA do microdisplay (bolsão raso, lente do lado da câmera)
        translate([camera_side*(cc_front/2) - camera_side*(lens_w/2 - display_bay_w/2),
                   rim_outer_h/2 - rim_t - display_bay_h/2, front_t - 2.5])
            cube([display_bay_w, display_bay_h, 3], center = true);
    }
}

// ============================================================================
//  02 — HASTE  (seção reta afilada + gancho de orelha curvo)
// ============================================================================
module xsec_lin(x, s) { translate([x, 0, zc]) capsule_xsec(s); }
module hook_xsec(a, s) {
    translate([temple_straight + ear_hook_radius*sin(a), 0, zc - ear_hook_radius + ear_hook_radius*cos(a)])
        rotate([0, a, 0]) capsule_xsec(s);
}

module temple_outer() {
    steps = 30;
    union() {
        // seção reta afilada (dois trechos p/ transição suave)
        hull() { xsec_lin(0, 1.0); xsec_lin(temple_straight*0.5, (1 + taper_end)/2); }
        hull() { xsec_lin(temple_straight*0.5, (1 + taper_end)/2); xsec_lin(temple_straight, taper_end); }
        // gancho de orelha
        for (i = [0 : steps - 1]) {
            s0 = taper_end*(1 - (1 - tip_scale)*i/steps);
            s1 = taper_end*(1 - (1 - tip_scale)*(i + 1)/steps);
            hull() { hook_xsec(ear_hook_angle*i/steps, s0); hook_xsec(ear_hook_angle*(i + 1)/steps, s1); }
        }
    }
}

module temple(elec = true) {
    difference() {
        temple_outer();
        // compartimento interno (bay), centrado em zc
        translate([bay_start, -bay_w/2, zc - bay_h/2]) cube([bay_len - cap_depth, bay_w, bay_h]);
        // abertura traseira (tampa / entrada do cartucho)
        translate([bay_start + bay_len - cap_depth, -bay_w/2, zc - bay_h/2]) cube([cap_depth + 1, bay_w, bay_h]);
        // rasgos do trilho (fêmea) — cavados para dentro das paredes laterais
        for (sy = [-1, 1])
            translate([bay_start, sy < 0 ? -bay_w/2 - rail_d : bay_w/2, zc - rail_h/2])
                cube([bay_len - cap_depth, rail_d, rail_h]);
        // janela do conector plugável (lado da dobradiça)
        translate([bay_start - 0.5, -conn_w/2, zc - conn_h/2]) cube([wall + 1, conn_w, conn_h]);
        // portas acústicas
        if (elec) {
            translate([bay_start + 8, 0, zc - temple_h/2 - 1]) cylinder(h = wall + 2, d = mic_port_d);
        } else {
            for (i = [0, 1])
                translate([temple_straight - 16 + i*6, 0, zc])
                    rotate([90, 0, 0]) cylinder(h = temple_w + 2, d = acoustic_port_d, center = true);
        }
    }
    // divisória da câmara acústica (haste esquerda)
    if (!elec)
        translate([temple_straight - 22, -bay_w/2, zc - bay_h/2]) cube([spk_divider_t, bay_w, bay_h]);
}

// ============================================================================
//  08 — CARTUCHO REMOVÍVEL  (arredondado, afilado, com pega)
// ============================================================================
module cartridge(elec = true) {
    difference() {
        union() {
            // corpo afilado (hull de duas seções)
            hull() {
                translate([1, 0, cart_h/2]) rbox_c(2, cart_w, cart_h, min(cart_w, cart_h)/2);
                translate([cart_len - 1, 0, cart_h/2]) rbox_c(2, cart_w*cart_taper, cart_h*cart_taper, min(cart_w, cart_h)/2*cart_taper);
            }
            // nervuras do trilho (macho)
            for (sy = [-1, 1])
                translate([0, sy < 0 ? -cart_w/2 - (rail_d - rail_tol) : cart_w/2, cart_h/2 - rail_h/2])
                    cube([cart_len, rail_d - rail_tol, rail_h - 2*rail_tol]);
            // trava snap
            translate([cart_len - latch_w, -cart_w/2, cart_h]) cube([latch_w, cart_w, latch_h]);
        }
        // bolsão da eletrônica (VOLUME RESERVADO — visual)
        translate([4, -cart_w/2 + 1.2, 1.2]) cube([cart_len - 8, cart_w - 2.4, cart_h - 2.0]);
        // recorte do conector
        translate([-1, -conn_w/2, cart_h/2 - conn_h/2]) cube([conn_w, conn_w, conn_h]);
        // ranhuras de pega na traseira
        for (i = [0 : grip_ridges - 1])
            translate([cart_len - 1.5 - i*1.6, -cart_w/2 - 1, -1])
                cube([0.7, cart_w + 2, cart_h + 2]);
    }
}

// ============================================================================
//  10 — TAMPA COM CANALETA DE VEDAÇÃO
// ============================================================================
module cap_gasket_groove(plug_w, plug_h) {
    difference() {
        cube([groove_w, plug_w + 2, plug_h + 2], center = true);
        cube([groove_w + 2, plug_w + 2 - 2*groove_d, plug_h + 2 - 2*groove_d], center = true);
    }
}

module end_cap() {
    plug_w = bay_w - 2*fit_tol;
    plug_h = bay_h - 2*fit_tol;
    zcap = wall + fit_tol + plug_h/2;
    difference() {
        union() {
            // flange externo arredondado (batente contra o casco)
            translate([0, 0, temple_h/2]) rbox_c(cap_flange, temple_w*taper_end, temple_h*taper_end, min(temple_w, temple_h)/2*taper_end);
            // plugue que entra na abertura
            translate([cap_flange, -plug_w/2, wall + fit_tol]) cube([cap_depth - fit_tol, plug_w, plug_h]);
        }
        translate([cap_flange + 2, 0, zcap]) cap_gasket_groove(plug_w, plug_h);
    }
}

// ============================================================================
//  LAYOUT DE CONFERÊNCIA
// ============================================================================
module layout() {
    front();
    translate([0, -62, 0])  temple(elec = true);
    translate([0, -84, 0])  cartridge(elec = true);
    translate([0, -106, 0]) mirror([0, 1, 0]) temple(elec = false);
    translate([0, -128, 0]) cartridge(elec = false);
    translate([0, -146, 0]) end_cap();
}

// ============================================================================
//  SELETOR
// ============================================================================
if      (part == "front")           front();
else if (part == "temple_right")    temple(elec = true);
else if (part == "temple_left")     mirror([0, 1, 0]) temple(elec = false);
else if (part == "cartridge_right") cartridge(elec = true);
else if (part == "cartridge_left")  cartridge(elec = false);
else if (part == "end_cap")         end_cap();
else                                layout();
