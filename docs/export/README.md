# Exportación Web — plantillas de Godot

El editor y las plantillas deben corresponder a la misma versión. El proyecto
usa Godot **4.7.2.stable**. El preset Web tiene `variant/thread_support=false`
y no define plantillas personalizadas, por lo que requiere estos archivos:

```text
~/.local/share/godot/export_templates/4.7.2.stable/web_nothreads_debug.zip
~/.local/share/godot/export_templates/4.7.2.stable/web_nothreads_release.zip
```

## Si aparece «No export template found at the expected path»

1. Abrir **Editor → Gestionar plantillas de exportación**.
2. Descargar e instalar las plantillas de la versión exacta del editor.
3. Como alternativa, descargar el paquete Standard `.tpz` desde el
   [archivo oficial de Godot 4.7.2](https://godotengine.org/download/archive/4.7.2-stable/)
   y elegir **Instalar desde archivo** en ese gestor.
4. Volver a abrir la ventana de exportación para actualizar la validación.

No hay que activar threads ni cambiar de versión para resolver la ausencia de
plantillas. `scripts/setup_tools.sh` prepara solo plantillas Android personalizadas;
no instala automáticamente las Web en el directorio del usuario.

## Instalación local del 05/10/2026

Se extrajeron las plantillas Web oficiales y `version.txt` al directorio del
usuario indicado arriba. Paquete descargado desde `godotengine/godot-builds`,
verificado con el SHA-512 de `SHA512-SUMS.txt` de la misma release y comprobación
CRC de los ZIP instalados. Las plantillas quedan fuera del repositorio.

Esta comprobación valida los archivos de instalación; no valida un export ni
su ejecución en navegador. No se exportó el juego. La exportación y publicación
Web siguen siendo manuales del usuario, en `TestWeb/`, ignorado por Git.

[Documentación oficial de exportación](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_projects.html).

## Exportación con música y efectos

La corrección de canales Web del 05/10/2026 requiere volver a exportar para
incluir el nuevo gestor de audio. Subir todos los archivos juntos, incluidos
los worklets de audio; no mezclar `.pck` nuevo con `.js`/`.wasm` antiguos.
Ver [diagnóstico, pruebas y solución de audio](../audio/README.md#silencio-en-web-canales-dinámicos--05102026).
