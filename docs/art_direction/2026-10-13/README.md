> **Estado 13/10/2026:** cuatro protagonistas: Nicolás, Carpintero; Inés, Constructora; Mauro, Boticario; Vera, Profesora. El contenido y la compatibilidad de seis personajes descritos anteriormente quedan sustituidos por el [retiro definitivo](../../cleanup/2026-10-13.md). Los resultados históricos no son pruebas del cambio actual.

# Cuatro héroes y cuaderno de bocetos — 13/10/2026

[Revisión visual posterior al campamento e interiores](review/README.md):
634 imágenes, 42 PNG actualizados y 502 PNG anteriores con consumidor resuelto;
pendientes por pantalla, mazmorras, mapas, iconos y animaciones.

## Dirección elegida por el usuario

Elenco activo: **Guerrero, Guardiana, Pícaro y Maga**. Seis parejas posibles.
Estética: arte conceptual con aspecto de lápiz/grafito sobre papel, líneas de
construcción, contornos incompletos y desprolijidades visibles. Paleta negra,
gris y violeta inspirada en Inicio. La última corrección pide mayor contraste
sobre personajes y pigmento violeta más firme, conservando el boceto.

El arte es generado mediante ImageGen; “dibujado a mano” describe el aspecto
buscado, no una afirmación de autoría humana. [Prompts](prompts.json) y
[procedencia/hash de las cuatro iteraciones](sources.json). La hoja aceptada
es `sources/contrast.png`, copiada sin repintado a
`assets/heroes/identity/sketchbook.png`. Recortes de rostro/torso mediante
AtlasTexture en `refuge_portrait.gd`, reutilizados entre galerías.

## Implementado ahora

- [Seis interiores sketchbook](../../base_camp/interiors/README.md) y galerías
  de cuatro héroes ampliadas a la derecha en dos filas de dos.

- Exterior del campamento: [rediseño crepuscular sketchbook](../../base_camp/dusk/README.md),
  con paisaje, seis edificios, entrenamiento, solares y fogata de 24 cuadros.

- Selección nueva alrededor de la fogata: cuatro posiciones, dos héroes por pareja.
- Mercado, herrería, iglesia, refugio, vínculos y entrenamiento: galerías activas
  de cuatro héroes; retratos del nuevo cuaderno y entradas centradas donde corresponde.
- Marcos compartidos: líneas discretamente irregulares gris/violeta junto al borde,
  menos ornamento y sin dorado. Texto gris claro; información funcional legible.
- Contratos nuevos: 19 de las 30 definiciones son compatibles con el elenco activo;
  seis de pareja. Se preservan contratos de aventuras en curso. Al volver a un
  campamento sin aventura activa se sustituyen ofertas que exijan héroes retirados,
  conservando una selección válida y evitando duplicados. RNG independiente.
- Logro de completar con todas las clases: cuatro héroes activos. Colección oculta
  los dos logros individuales legados no obtenidos y sus cartas bloqueadas, pero
  conserva logros/cartas ya obtenidos y todo el historial. Hay 28 hitos visibles
  para un perfil nuevo y hasta 30 con hitos legados.
- Historias: cuatro héroes para perfiles nuevos; relatos legados vistos permanecen
  accesibles. La intro dice “Cuatro caminos”. Definiciones antiguas conservadas.
- Regresiones: datos de prueba de Godot aislados por suite con `XDG_DATA_HOME`,
  incluyendo instancias iniciales de `Game.new()` creadas por `main.tscn`.

## Compatibilidad

`rules/hero_roster.gd` define el elenco visible, sin eliminar los seis IDs de
contenido, cartas, poses, mejoras o especializaciones existentes. La API de reglas
sigue admitiendo parejas legadas; aventuras antiguas se pueden cargar y continuar
con su mazo y contrato. No se cambian el formato del guardado ni costes/daño.
La nueva UI no permite escoger Clériga/Explorador para aventuras nuevas.

## Guía para continuar el arte

| Elemento | Regla |
| --- | --- |
| Papel | Gris con fibra/huellas de borrado discretas; no sepia predominante ni ruido sobre letras |
| Contorno | Grafito roto, grosor variable; líneas de búsqueda junto a silueta |
| Sombra | Carbonilla negra y tramado visible, sin degradado plástico |
| Color | Violeta profundo en tela; gris claro en acero; piel/cabello secundarios |
| Personajes | Casco cerrado/asimetría del Guerrero; escudo recortado/trenza de Guardiana; rostro visible/capucha abierta de Pícaro; pelo corto/bastón de aro de Maga |
| Efectos | Gestos dibujados y pocos acentos; rojo para vida y verde para veneno siguen diferenciándose |
| Interfaz | Zona de lectura limpia; marcas de lápiz en bordes, nunca encima del texto |

## Mecánicas: foco de las seis parejas

Estos son objetivos de diseño para probar, **no reglas nuevas implementadas**:

| Pareja | Decisión que conviene explorar |
| --- | --- |
| Guerrero + Guardiana | Ceder protección para preparar un golpe fuerte |
| Guerrero + Pícaro | Abrir una defensa y elegir quién aprovecha la apertura |
| Guerrero + Maga | Interrumpir/preparar y decidir el orden de dos impactos |
| Guardiana + Pícaro | Defender mientras madura el veneno o acelerar el daño |
| Guardiana + Maga | Mantener una canalización o gastar protección en una urgencia |
| Pícaro + Maga | Marcar un objetivo y decidir entre concentrarse o propagar |

Guerrero, Guardiana y Maga ya tienen cartas que curan; Pícaro no. Al probar la
primera mazmorra sin Clériga hay que evaluar recuperación y dependencia de objetos,
sin compensarla agregando mejoras permanentes arbitrarias.

## Alcance visual pendiente

El concepto ya se aplica a retratos, primeros planos, marcos, campamento e
interiores. **Los sprites de combate/correr/descanso, cartas, enemigos,
escenarios de aventura y planos de cinemáticas conservan su arte anterior.**
El [inventario posterior](review/README.md) separa arte activo, actualizado y
condicional. No se afirma una conversión completa del juego.
No se superpone un filtro de “papel” para fingir nuevos dibujos ni se reemplazan
poses animadas por las cuatro figuras estáticas.

Próxima aplicación coherente: actores de los cuatro protagonistas y una
mazmorra con enemigos, poses y efectos completos, usando las referencias
individuales actuales. Mantener los sprites anteriores hasta comprobar cada
reemplazo en movimiento y a tamaño real.

Pruebas del concepto inicial: [validation.json](validation.json). Las entregas
posteriores documentan sus propias comprobaciones. Sin exportación Web/APK.

## Ajuste narrativo posterior del 13/10

Los nombres de trabajo son Nicolás (carpintero), Inés (albañila), Mauro
(boticario) y Vera (maestra/escribiente). Las galerías muestran nombres/oficios
y el Pícaro usa un retrato independiente con el rostro visible, sin máscara.
La hoja inicial permanece como referencia de los otros tres; no se borran
las fuentes de iteraciones anteriores. [Vida civil, arte y límites actuales](../../story/2026-10-13/README.md).
