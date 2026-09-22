# Movimiento dibujado en los ataques en primer plano

## Alcance

24 secuencias, cuatro variantes por cada uno de los seis héroes. Cada secuencia
contiene cuatro dibujos: preparación, carga, impacto/lanzamiento y recuperación.
Mantienen la identidad y acción de las ilustraciones estáticas existentes.

| Héroe | Variante 0 | Variante 1 | Variante 2 | Variante 3 |
| --- | --- | --- | --- | --- |
| Guerrero | Corte horizontal | Corte ascendente | Tajo descendente | Estocada |
| Guardiana | Golpe de escudo | Embestida | Escudo ascendente | Escudo descendente |
| Pícaro | Corte doble | Estocada | Corte cruzado | Puñalada descendente |
| Maga | Proyectil de hielo | Lanza de cristal | Abanico de hielo | Orbe arcano |
| Clériga | Luz desde la palma | Lanza sagrada | Arco de luz | Estallido sagrado |
| Explorador | Disparo de pie | Arrodillado | Disparo en salto | Abanico de flechas |

## Presentación

`hero_cut_in.gd` selecciona `assets/comic/motion/<héroe>_<variante>.png` y activa
la cuadrícula 2×2 de `comic_cut_in.gd`. El componente compartido usa AtlasTexture
para mostrar un cuadro cada 0,18 s (0,72 s totales), sin cargar texturas por cuadro.
Se conserva entrada desde la izquierda, posición inferior, transparencia y capa
por debajo de los modales. Defensa y ataques enemigos continúan como imágenes
individuales; su comportamiento no se cambia con esta entrega.

La rotación de variantes y los combos siguen en el flujo existente: una secuencia
completa por golpe resuelto, sin consumir RNG de aventura ni alterar daño,
contraataques, guardado o cantidad de golpes. El avance de cuadros no decide reglas.

## Assets y procedencia

- Referencias: los seis cómics originales y las 18 variantes de `assets/comic/attacks/`.
- Generación: habilidad imagegen, herramienta integrada; una hoja por variante.
- `prompts.json`: instrucciones por hoja. `spacing-prompts.json`: correcciones
  para separar armas y efectos entre cuadros.
- `sources.json`: referencias y rutas de generación; originales finales en `sources/`.
- Fuentes RGBA de 1536×1024, cuatro celdas 768×512.
- Importador `scripts/import_comic_motion.gd`: usa un único recorte común a las
  cuatro poses para preservar posiciones relativas (silueta opaca con 12 px de
  margen para efectos); escala uniforme y margen
  transparente. Destinos 1200×800, cuatro cuadros 600×400, filtrado lineal.
- Se conservan los originales: también se usan como ilustraciones fuera del
  combate. Las fuentes en docs quedan fuera de la exportación.

## Verificación

`test_comic_motion.gd` comprueba las 24 variantes, transparencia, cuatro dibujos
distintos, regiones válidas y reproducción de los cuatro cuadros en orden.
Las regresiones de viñetas y contraataques verifican rotación, anclaje, limpieza
y combos de dos/tres golpes. Resultados ejecutados en `docs/HISTORIAL.md`.
No exportar Web/APK salvo pedido explícito; validación local separada de móvil.
