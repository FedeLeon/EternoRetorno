# Variedad de enemigos y cómics fluidos — 30/09/2026

> El formato de ocho cuadros de héroes de esta entrega quedó sustituido el
> 01/10/2026 por [16 cuadros y nuevos efectos](../comic/smooth/README.md).
> Sus fuentes y pruebas de ocho cuadros se conservan como registro histórico;
> el importador delega ahora al empaquetador vigente para los héroes.


## Enemigos

Se activan seis conceptos existentes de la biblioteca del usuario; no se sustituyen
los enemigos previos. Cada incorporación tiene ocho poses de escenario (cuatro
de reposo y cuatro de ataque) y una ilustración de ataque en primer plano hacia
la izquierda, con transparencia.

| Mazmorra | Enemigo / ID de reglas | Concepto visual | Desde etapa |
| --- | --- | --- | ---: |
| Cripta | Chamán esqueleto / `skeleton_mage` | `skeleton_4` | 3 |
| Cripta | Elemental de fuego / `fire_elemental` | `elemental_0` | 5 |
| Cripta | Escarabajo coraza / `armored_beetle` | `crypt_beetle` | 2 |
| Bosque | Bandido arquero / `bandit_archer` | `bandit_2` | 1 |
| Bosque | Sapo venenoso / `poison_toad` | `beast_4` | 2 |
| Bosque | Elemental de raíces / `root_elemental` | `elemental_6` | 4 |

Etapas contadas desde cero. La cripta pasa de 10 a 13 enemigos comunes y el bosque
de 11 a 14: **31 enemigos activos** incluyendo élites y guardianes.
`data/enemy_expansion.json` declara vida y patrones usando daño, bloqueo,
contraataque y ataques a ambos héroes ya existentes. El sapo representa su ataque
como una descarga de daño; no agrega un estado de veneno a héroes.

`data/dungeons.json` integra el catálogo al generador aleatorio actual, conservando
inventario de salas y formaciones. Los encuentros ya guardados no se vuelven a
sortear; la variedad se ve en pisos generados después del cambio.

## Héroes

- 24 variantes ofensivas, ahora con **ocho dibujos por secuencia**, y seis defensas
  nuevas también de ocho dibujos: **240 cuadros** en total.
- Las poses cambian armas, brazos, capa y efectos; no son duplicados de una imagen.
- Cada secuencia dura 0,72 s, un cuadro cada 0,09 s. Los combos conservan una
  secuencia distinta por cada golpe y la defensa sigue correspondiendo al objetivo.
- Ataques y defensas comparten escala 1,28 y desplazamiento relativo (-0,10; 0,12).
  La esquina inferior izquierda admite un recorte leve y mantiene el resto del
  escenario visible. Los enemigos conservan el encuadre desde la derecha.
- Destellos sobre el dibujo, halo tenue y chispas del color del héroe detrás.
  No hay panel opaco ni oscurecimiento general; efectos en capa 150, bajo modales.
- Todo vive en presentación: no calcula daño, no consume RNG de aventura y no
  modifica la resolución ni el guardado previos a las animaciones.

## Assets y reproducción

Generados con la habilidad `imagegen` y la herramienta integrada, una hoja o
ilustración por llamada. `prompts.json` conserva las instrucciones exactas;
`sources.json`, la referencia y ruta de cada resultado. `spacing-prompts.json`
registra la corrección de hojas cuyos efectos tocaban el borde de una celda.
Originales finales en `sources/`.
Las referencias de héroes son las secuencias/defensas anteriores; las de enemigos,
los sprites HD derivados de las plantillas del usuario.

Importación local: `./scripts/run.sh --headless --script scripts/import_combat_expansion.gd`.

- Héroes: hojas 4×2, empaquetadas en 2400×800 con cuadros 600×400, recorte común
  y escala uniforme para preservar posiciones relativas. Rutas de los 24 ataques
  conservadas; defensas en `assets/comic/motion/<héroe>_defense.png`.
- Enemigos: hojas 4×2, empaquetadas por `enemy_art_import.gd` en 1024×128 con
  ocho cuadros de 128×128 y línea de suelo compartida. Cómics reducidos a 900 px.
- Cómics con compresión de importación Lossy 0,85, sin reducción automática del
  atlas; sprites de escenario sin pérdida. Fuentes en docs excluidas de exportación.
- Se conservan retratos estáticos y fuentes anteriores para las otras vistas y
  procedencia. El importador anterior de cómics delega al nuevo formato.

## Validación

Las pruebas `test_comic_motion.gd`, `test_hero_cut_in.gd` y
`test_combat_expansion.gd` cubren cuadros distintos, alfa, reproducción ordenada,
encuadre, limpieza, encuentros progresivos y patrones de los seis enemigos.
Regresiones de generación, guardados, combos y turno: resultados concretos en
`docs/HISTORIAL.md`. Las capturas temporales quedan en `artifacts/`.
El balance se propone como punto de partida; requiere pruebas de partidas completas.
