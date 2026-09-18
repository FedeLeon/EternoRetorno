# Limpieza del proyecto

## Auditoría actual — 18/09/2026

[Informe e inventario de archivos retirados](cleanup/2026-09-18.md): 15 archivos
obsoletos, aproximadamente 8,6 MiB. Extracción de pantalla/flujo de combate y
reglas de consumibles; 30/30 pruebas automatizadas aprobadas.

## Registro histórico — 16/09/2026

## Criterio

Se retiraron 243 archivos (61 023 157 bytes, aproximadamente 58,2 MiB), además
de cachés Python. No se eliminaron partidas, herramientas Android, APK existentes
ni cambios funcionales pendientes del usuario.

- Atlas de seis héroes y selección a 64 px reemplazados por los de 128 px.
- 56 sprites antiguos de enemigos reemplazados por la biblioteca `hd/`.
- Capturas de escritorio/Android, vídeos y logs de pruebas acumulados.
- Dos fuentes descartadas: primer ensayo del guerrero y cofre previo al alfa final.
- `tests/capture_screens.gd`: generador de capturas duplicado por pruebas de pantallas.
- `tests/android_smoke.py`: recorrido con coordenadas y flujo anteriores al campamento,
  equipamiento y HUD actuales. No validaba la versión actual; será necesario un nuevo
  recorrido cuando se solicite probar/exportar Android.
- Dibujos de personajes provisionales en `pixel_art.gd` y rama de fallback en `main.gd`.
  El fondo procedural se conserva porque mapa/recompensas/colección todavía lo usan.

## Qué se conserva y por qué

Las pruebas `tests/test_*.gd` verifican reglas, guardados, equipos e interfaz;
no forman parte del juego exportado. No se borran por ser archivos de prueba.
Los `.gd.uid` y los `.import` de recursos activos son metadatos de Godot.
Se conservan 28 fuentes PNG usadas por importadores y los prompts de procedencia.
Los 56 enemigos actuales incluyen los reservados para futuras mazmorras.
La fogata sigue usando `fire-64.png`: no tiene un reemplazo y permanece activa.

## Para no volver a acumular capturas

Los tests y la vista previa guardan PNG en `artifacts/<sistema>/`, mediante
`tests/artifacts.gd`. Carpeta ignorada por Git, excluida de exportación y con
`.gdignore` creado automáticamente. Se puede borrar completa después de revisar.
Los cuadros de la vista previa animada siguen en `user://actor-preview`.
`docs/` se reserva para documentación, decisiones, prompts y fuentes de arte útiles.
Las menciones de capturas en entradas históricas describen pruebas de su fecha;
los archivos correspondientes fueron eliminados. Los enlaces se retiraron.

## Inventario de archivos eliminados

- `assets/enemies/crypt_lancer.png`
- `assets/enemies/elemental_5.png`
- `assets/enemies/flying_2.png`
- `assets/enemies/beast_4.png`
- `assets/enemies/bandit_3.png`
- `assets/enemies/goblin_1.png`
- `assets/enemies/beast_0.png`
- `assets/enemies/flying_3.png`
- `assets/enemies/goblin_2.png`
- `assets/enemies/crypt_slime.png`
- `assets/enemies/crypt_automaton.png`
- `assets/enemies/goblin_4.png`
- `assets/enemies/bandit_5.png`
- `assets/enemies/skeleton_3.png`
- `assets/enemies/goblin_5.png`
- `assets/enemies/crypt_wolf.png`
- `assets/enemies/flying_4.png`
- `assets/enemies/beast_5.png`
- `assets/enemies/beast_6.png`
- `assets/enemies/flying_0.png`
- `assets/enemies/beast_2.png`
- `assets/enemies/skeleton_4.png`
- `assets/enemies/skeleton_1.png`
- `assets/enemies/goblin_0.png`
- `assets/enemies/skeleton_5.png`
- `assets/enemies/bandit_2.png`
- `assets/enemies/crypt_bat.png`
- `assets/enemies/elemental_3.png`
- `assets/enemies/bandit_4.png`
- `assets/enemies/elemental_2.png`
- `assets/enemies/flying_7.png`
- `assets/enemies/flying_6.png`
- `assets/enemies/beast_7.png`
- `assets/enemies/skeleton_6.png`
- `assets/enemies/elemental_7.png`
- `assets/enemies/elemental_6.png`
- `assets/enemies/beast_1.png`
- `assets/enemies/beast_3.png`
- `assets/enemies/skeleton_7.png`
- `assets/enemies/bandit_0.png`
- `assets/enemies/goblin_3.png`
- `assets/enemies/bandit_7.png`
- `assets/enemies/crypt_beetle.png`
- `assets/enemies/crypt_bandit.png`
- `assets/enemies/skeleton_2.png`
- `assets/enemies/goblin_6.png`
- `assets/enemies/elemental_4.png`
- `assets/enemies/flying_5.png`
- `assets/enemies/elemental_1.png`
- `assets/enemies/flying_1.png`
- `assets/enemies/goblin_7.png`
- `assets/enemies/elemental_0.png`
- `assets/enemies/skeleton_0.png`
- `assets/enemies/bandit_6.png`
- `assets/enemies/bandit_1.png`
- `assets/enemies/crypt_shaman.png`
- `assets/rogue/rogue-64.png`
- `assets/mage/mage-64.png`
- `assets/warrior/warrior-64.png`
- `assets/camp/front-64.png`
- `assets/cleric/cleric-64.png`
- `assets/ranger/ranger-64.png`
- `assets/guardian/guardian-64.png`
- `docs/android-03-mapa.png`
- `docs/android-06-recompensa.png`
- `docs/09-coleccion.png`
- `docs/07-descanso.png`
- `docs/06-recompensa.png`
- `docs/android-04-combate.png`
- `docs/android-02-personajes.png`
- `docs/android-10-victory.png`
- `docs/android-01-inicio.png`
- `docs/08-mazo.png`
- `docs/android-smoke.log`
- `docs/android-09-escalera.png`
- `docs/02-personajes.png`
- `docs/01-inicio.png`
- `docs/05-objetivos.png`
- `docs/10-victoria.png`
- `docs/game-tests.log`
- `docs/03-mapa.png`
- `docs/04-combate.png`
- `docs/android-07-descanso.png`
- `docs/ui-tests.log`
- `docs/android-05-pausa.png`
- `docs/android-08-mejora.png`
- `docs/treasure/battle-2.png`
- `docs/treasure/battle-4.png`
- `docs/treasure/closed.png`
- `docs/treasure/trap.png`
- `docs/treasure/opened.png`
- `docs/treasure/battle-0.png`
- `docs/treasure/chest-source-initial.png`
- `docs/title/home.png`
- `docs/title/options.png`
- `docs/rogue/selection.png`
- `docs/rogue/rogue_echo.png`
- `docs/rogue/revive.png`
- `docs/rogue/rogue_toxin.png`
- `docs/rogue/fallen.png`
- `docs/rogue/hurt.png`
- `docs/rogue/idle.png`
- `docs/rogue/poison.png`
- `docs/rogue/attack.png`
- `docs/rogue/rogue_dodge.png`
- `docs/mage/selection.png`
- `docs/mage/mage_echo.png`
- `docs/mage/revive.png`
- `docs/mage/mage_ward.png`
- `docs/mage/heavy.png`
- `docs/mage/fallen.png`
- `docs/mage/hurt.png`
- `docs/mage/idle.png`
- `docs/mage/attack.png`
- `docs/mage/mage_missile.png`
- `docs/base_camp/base-camp.png`
- `docs/warrior/selection.png`
- `docs/warrior/revive.png`
- `docs/warrior/heavy.png`
- `docs/warrior/android-idle.png`
- `docs/warrior/fallen.png`
- `docs/warrior/android-test.log`
- `docs/warrior/android-attack.png`
- `docs/warrior/hurt.png`
- `docs/warrior/idle.png`
- `docs/warrior/generated-first.png`
- `docs/warrior/tests.log`
- `docs/warrior/attack.png`
- `docs/camp/camp-first.png`
- `docs/camp/camp-second.png`
- `docs/camp/camp-selected.png`
- `docs/cleric/selection.png`
- `docs/cleric/cleric_heal.png`
- `docs/cleric/revive.png`
- `docs/cleric/cleric_echo.png`
- `docs/cleric/fallen.png`
- `docs/cleric/hurt.png`
- `docs/cleric/idle.png`
- `docs/cleric/judgment.png`
- `docs/cleric/cleric_ward.png`
- `docs/cleric/attack.png`
- `docs/quality/actors.png`
- `docs/quality/actors.mp4`
- `docs/objects/loadout.png`
- `docs/objects/expanded-hand.png`
- `docs/objects/bag.png`
- `docs/ranger/ranger_double.png`
- `docs/ranger/selection.png`
- `docs/ranger/revive.png`
- `docs/ranger/heavy.png`
- `docs/ranger/fallen.png`
- `docs/ranger/hurt.png`
- `docs/ranger/ranger_echo.png`
- `docs/ranger/ranger_evade.png`
- `docs/ranger/idle.png`
- `docs/ranger/attack.png`
- `docs/dungeon/selected-card.png`
- `docs/dungeon/combat.png`
- `docs/cards/gallery.png`
- `docs/hud/relic-popover.png`
- `docs/hud/zero-energy.png`
- `docs/hud/combat.png`
- `docs/hud/energy-frame-a.png`
- `docs/hud/energy-frame-b.png`
- `docs/guardian/selection.png`
- `docs/guardian/hurt.png`
- `docs/guardian/guard.png`
- `docs/guardian/bash.png`
- `docs/guardian/idle.png`
- `docs/guardian/attack.png`
- `docs/enemies/gallery.png`
- `docs/enemies/combat-rat.png`
- `docs/enemies/combat-boss.png`
- `docs/enemies/combat-skeleton.png`
- `docs/enemies/combat-elite.png`
- `docs/enemies/combat-slime.png`
- `docs/enemies/combat-cultist.png`
- `tests/android_smoke.py`
- `tests/capture_screens.gd`
- `assets/enemies/crypt_lancer.png.import`
- `assets/enemies/elemental_5.png.import`
- `assets/enemies/flying_2.png.import`
- `assets/enemies/beast_4.png.import`
- `assets/enemies/bandit_3.png.import`
- `assets/enemies/goblin_1.png.import`
- `assets/enemies/beast_0.png.import`
- `assets/enemies/flying_3.png.import`
- `assets/enemies/goblin_2.png.import`
- `assets/enemies/crypt_slime.png.import`
- `assets/enemies/crypt_automaton.png.import`
- `assets/enemies/goblin_4.png.import`
- `assets/enemies/bandit_5.png.import`
- `assets/enemies/skeleton_3.png.import`
- `assets/enemies/goblin_5.png.import`
- `assets/enemies/crypt_wolf.png.import`
- `assets/enemies/flying_4.png.import`
- `assets/enemies/beast_5.png.import`
- `assets/enemies/beast_6.png.import`
- `assets/enemies/flying_0.png.import`
- `assets/enemies/beast_2.png.import`
- `assets/enemies/skeleton_4.png.import`
- `assets/enemies/skeleton_1.png.import`
- `assets/enemies/goblin_0.png.import`
- `assets/enemies/skeleton_5.png.import`
- `assets/enemies/bandit_2.png.import`
- `assets/enemies/crypt_bat.png.import`
- `assets/enemies/elemental_3.png.import`
- `assets/enemies/bandit_4.png.import`
- `assets/enemies/elemental_2.png.import`
- `assets/enemies/flying_7.png.import`
- `assets/enemies/flying_6.png.import`
- `assets/enemies/beast_7.png.import`
- `assets/enemies/skeleton_6.png.import`
- `assets/enemies/elemental_7.png.import`
- `assets/enemies/elemental_6.png.import`
- `assets/enemies/beast_1.png.import`
- `assets/enemies/beast_3.png.import`
- `assets/enemies/skeleton_7.png.import`
- `assets/enemies/bandit_0.png.import`
- `assets/enemies/goblin_3.png.import`
- `assets/enemies/bandit_7.png.import`
- `assets/enemies/crypt_beetle.png.import`
- `assets/enemies/crypt_bandit.png.import`
- `assets/enemies/skeleton_2.png.import`
- `assets/enemies/goblin_6.png.import`
- `assets/enemies/elemental_4.png.import`
- `assets/enemies/flying_5.png.import`
- `assets/enemies/elemental_1.png.import`
- `assets/enemies/flying_1.png.import`
- `assets/enemies/goblin_7.png.import`
- `assets/enemies/elemental_0.png.import`
- `assets/enemies/skeleton_0.png.import`
- `assets/enemies/bandit_6.png.import`
- `assets/enemies/bandit_1.png.import`
- `assets/enemies/crypt_shaman.png.import`
- `assets/rogue/rogue-64.png.import`
- `assets/mage/mage-64.png.import`
- `assets/warrior/warrior-64.png.import`
- `assets/camp/front-64.png.import`
- `assets/cleric/cleric-64.png.import`
- `assets/ranger/ranger-64.png.import`
- `assets/guardian/guardian-64.png.import`
- `tests/capture_screens.gd.uid`

## Validación posterior

19 suites headless: **1717 comprobaciones, cero fallos**; 45/45 aventuras simuladas.
También se ejecutaron renderizados `test_enemies.gd` (498) y `test_treasure_ui.gd`
(8), verificando que las capturas se crean en `artifacts/` sin reponer archivos
en `docs/`. Se revisaron galería y combate y después se borraron esas capturas.
Importación y revisión de referencias sin recursos faltantes; `git diff --check`
correcto. No se compiló APK ni se probó Android.
