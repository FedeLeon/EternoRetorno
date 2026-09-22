# Cartas de apoyo y debilitamiento — 22/09/2026

24 cartas nuevas, cuatro por héroe: catálogo total de **114**, con **60 comprables**
(diez por héroe). Se agregan al mercado existente; no modifican los mazos iniciales
ni se insertan automáticamente en aventuras guardadas. Comprar habilita su aparición
aleatoria entre las tres recompensas de batalla compatibles con la pareja.

## Reglas de los porcentajes

- **Fuerza:** +25% al daño de cada golpe de las cartas del héroe elegido durante
  el turno actual. Se calcula después de equipo, especialización y bonificaciones
  de cartas de reliquias; el daño de veneno no aumenta. El Colmillo conserva su
  +1 independiente por impacto. En un enlace cada héroe potencia su mitad del daño.
- **Debilidad:** -25% al daño del ataque normal de la próxima acción del enemigo;
  también afecta a sus ataques grupales. El contraataque sigue causando 4 por golpe.
  Si la próxima acción no ataca, el efecto igualmente expira tras esa acción.
- **Fractura:** elimina el 25% del bloqueo actual antes de los golpes y reduce
  en 25% el bloqueo ganado en su próxima acción. No aumenta daño a PV ni resta
  armadura permanente. La reducción de bloqueo actual no se revierte al expirar.
- **No se suman:** repetir un estado conserva el porcentaje mayor. Pasar de 25%
  a 35% de fractura aplica solamente la diferencia sobre el bloqueo restante.
- Se redondea hacia abajo el daño/bloqueo resultante. Por ejemplo: daño 12 → 9
  con debilidad; bloqueo 20 → 15 con fractura; daño 8 → 10 con fuerza.
- Mejorar una carta sube sus porcentajes de **25% a 35%**, además de las mejoras
  existentes (+3 daño/bloqueo/curación, +2 veneno). El coste no cambia.
- Curación limitada a PV máximos y héroes vivos. Bloqueo/curación de cartas con
  objetivo enemigo benefician al dueño. Guerrero, guardiana, maga y explorador
  reciben nuevas opciones de curación, además de las nuevas cartas de la clériga.
- Estados guardados durante el combate y eliminados al empezar el turno siguiente
  o un nuevo combate; la fuerza también se limpia al ganar. No son mejoras del perfil.

## Catálogo añadido

Valores normales. Fuerza, debilidad y fractura usan las reglas anteriores.

## Guerrero

| Carta | Energía | Efecto | Almas |
| --- | --- | --- | --- |
| Grito de guerra (`warrior_rally`) | 1 | fuerza 25%. Aliado vivo | 180 |
| Segundo aliento (`warrior_second_wind`) | 1 | 4 bloqueo, cura 6. Dueño | 160 |
| Quebrar armadura (`warrior_crush_armor`) | 1 | 8 daño, fractura 25%. Un enemigo | 200 |
| Desarmar (`warrior_disarm`) | 1 | 5 daño, debilidad 25%. Un enemigo | 180 |

## Guardiana

| Carta | Energía | Efecto | Almas |
| --- | --- | --- | --- |
| Auxilio (`guardian_lay_hands`) | 1 | 4 bloqueo, cura 6. Aliado vivo | 170 |
| Valor compartido (`guardian_inspire`) | 2 | fuerza 25%. Ambos aliados | 230 |
| Embate de escudo (`guardian_shield_break`) | 2 | 6 daño, 6 bloqueo, fractura 25%. Un enemigo | 230 |
| Reprensión (`guardian_rebuke`) | 1 | 7 bloqueo, debilidad 25%. Un enemigo | 190 |

## Pícaro

| Carta | Energía | Efecto | Almas |
| --- | --- | --- | --- |
| Toxina debilitante (`rogue_enervating`) | 1 | 4 veneno, debilidad 25%. Un enemigo | 210 |
| Ácido corrosivo (`rogue_corrosive`) | 1 | 4 veneno, fractura 25%. Un enemigo | 210 |
| Adrenalina (`rogue_adrenaline`) | 1 | 5 bloqueo, fuerza 25%. Dueño | 180 |
| Herida abierta (`rogue_exposed`) | 2 | 9 daño penetrante, fractura 25%. Un enemigo | 220 |

## Maga

| Carta | Energía | Efecto | Almas |
| --- | --- | --- | --- |
| Enfoque arcano (`mage_focus`) | 1 | 4 bloqueo, fuerza 25%. Aliado vivo | 190 |
| Escarcha opresiva (`mage_frost_bind`) | 2 | 3 daño, debilidad 25%. Todos los enemigos | 240 |
| Cristal quebrado (`mage_shatter`) | 1 | 8 daño, fractura 25%. Un enemigo | 200 |
| Drenaje arcano (`mage_siphon`) | 1 | 7 daño, cura 4 al dueño. Un enemigo | 190 |

## Clériga

| Carta | Energía | Efecto | Almas |
| --- | --- | --- | --- |
| Bendición de valor (`cleric_benediction`) | 1 | cura 4, fuerza 25%. Aliado vivo | 190 |
| Absolución (`cleric_absolution`) | 2 | cura 6. Ambos aliados | 240 |
| Censura (`cleric_censure`) | 1 | debilidad 25%. Todos los enemigos | 200 |
| Juicio de luz (`cleric_radiant_judgment`) | 2 | 10 daño, fractura 25%. Un enemigo | 230 |

## Explorador

| Carta | Energía | Efecto | Almas |
| --- | --- | --- | --- |
| Primeros auxilios (`ranger_field_aid`) | 1 | cura 7. Aliado vivo | 160 |
| Pulso firme (`ranger_hunters_focus`) | 1 | 5 bloqueo, fuerza 25%. Dueño | 180 |
| Flecha al tendón (`ranger_tendon_shot`) | 1 | 6 daño, debilidad 25%. Un enemigo | 190 |
| Flecha astillada (`ranger_split_arrow`) | 2 | 5 × 2 daño, fractura 25%. Un enemigo | 230 |

## Arte y organización

- 24 ilustraciones individuales, creadas con la herramienta integrada **imagegen**.
  Referencia visual: `assets/cards/art/originals.png`; siluetas angulosas, fondos
  oscuros y gesto luminoso con la paleta de cada héroe. No se reemplaza arte previo.
- [Prompts completos](prompts.json), [procedencia por ID](sources.json) y fuentes
  originales en `sources/`. Finales: `assets/cards/art/<id>.png`, 512 px de ancho;
  los 24 PNG suman **5.66 MiB**. Las fuentes de documentación no se exportan.
- `scripts/import_support_cards.gd`: reducción determinista desde las fuentes.
  `data/card_art.json` registra todos los IDs. [Galería local](galeria.html).
- `data/support_cards.json`: catálogo adicional, unido por `content.gd`, sin
  ampliar el JSON original. `locked=false` sigue la convención de mercado:
  el requisito de compra depende de `market_price` y `profile.market_cards`,
  no del desbloqueo por primera victoria de una clase.
- `rules/combat_modifiers.gd`: porcentajes, duración, no acumulación y vista de
  intención efectiva. `game.gd` coordina aplicación/guardado, no la presentación.
- `ui/components/combat_modifier_badges.gd`: iconos pulsables con explicación
  en la arena; `card_type_icons.gd` añade sus símbolos a la pastilla. Tres SVG
  propios derivados del sistema vectorial existente: fuerza, debilidad y fractura.
- Nombres largos ajustados a una línea; textos comprobados en mano, carta
  seleccionada, mercado y mazo/mejora. Se mantiene la ilustración en su espacio.

## Validación local

- Reglas específicas: 1.922 comprobaciones sin fallos, incluyendo compras,
  recompensas, duración, no acumulación, curación, golpes múltiples, contraataque,
  porcentajes mejorados y guardado/reanudación.
- UI específica: 609 comprobaciones renderizadas; las 24 cartas normales y
  mejoradas en cuatro tamaños, intenciones ajustadas, indicadores y compra real.
- Ilustraciones: 715; progresión/mercado: 989; mercado renderizado: 49;
  cartas renderizadas: 701; reglas generales: 142; enlaces: 481;
  reliquias: 134 y equipo: 90. Sin fallos.
- Revisión visual de las seis galerías, mano, efectos y mercado en Linux,
  1280×720 con llvmpipe. Capturas temporales retiradas después de revisar.
- No se exportó Web/APK ni se validó en dispositivo. El balance de las cartas
  requiere partidas humanas; no se afirma equilibrio a partir de pruebas técnicas.
