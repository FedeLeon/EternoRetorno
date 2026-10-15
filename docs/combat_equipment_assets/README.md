# Celda de energía y mejoras de equipo de batalla

Dirección: cómic postapocalíptico de civiles contra máquinas, tinta negra,
sombras violetas, metal recuperado y acentos cian. Generado con la herramienta
integrada `image_gen.imagegen`; cinco fuentes RGBA, prompts y procedencia en
`jobs.json`, registros individuales y `sources/`.

## Recursos e integración

- `assets/ui/battle_energy_cell.png`: contador frontal con ventana oscura vacía.
  El número sigue siendo dinámico (EnergyNumber), centrado en la ventana;
  admite dos cifras. El shader pulsa únicamente los tubos laterales cian,
  sin desplazar el cuerpo ni iluminar el fondo del número.
- `assets/forge/badges/`: 24 PNG individuales de 512×512: cuatro personajes,
  dos pistas (weapon/armor) y tres niveles. Carpintero: sierra/delantal reforzado;
  Constructora: palanca/señal y chaleco; Boticario: cuchillo/inyección y chaqueta
  médica; Profesora: emisor electromagnético y abrigo aislante.
- `equipment_badges.gd` resuelve por ID, pista y nivel de la instantánea de la
  aventura. Conserva bonos, niveles y cuadros de explicación existentes.
- `combat_hud.gd` usa filtrado lineal; número de nivel alineado al borde del icono
  incluso cuando disminuye el espacio entre componentes. Compartido con premios.
- `scripts/import_combat_equipment_assets.gd` separa cada banco 3×2, recorta alfa
  y ajusta proporcionalmente a 512 px; fuente de cada pieza de aproximadamente
  512×512. Registra hashes y fuentes en el inventario de arte.
- Política de importación: compresión 2D con calidad 0.9 y límite 512 px.
  Fuentes de documentación excluidas de la exportación. Sin cambios de guardado.

## Validación

Resultados actuales se registran en `validation.json` y en el historial.
Revisión local nativa aislada, audio Dummy; sin exportación ni revisión Web.
