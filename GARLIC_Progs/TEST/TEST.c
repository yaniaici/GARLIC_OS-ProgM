#include "GARLIC_API.h"  /* Definición de las funciones API de GARLIC */

int _start(int arg)  /* Función de inicio : no se usa 'main' */
{
    char buffer[128];  // Buffer para almacenar cada línea
    int bytesRead;
    FILE_GARLIC *f;

    // Validar argumento dentro del rango permitido
    if (arg < 0) arg = 0;
    else if (arg > 3) arg = 3;

    // Mensaje inicial
    GARLIC_printf("-- Programa TEST -  PID (%d) --\n", GARLIC_pid());

    // Abrir el archivo
    f = GARLIC_fopen("file0", "r");
    GARLIC_printf("-- Archivo Abierto --\n");
    if (f == 0) {
        GARLIC_printf("-- No encontrado--\n");
        return 0;
    } else {
        GARLIC_printf("-- File opened: %x --\n", f);
    }

    GARLIC_printf("\n=== Contenido del archivo ===\n");

    // Leer y mostrar el contenido línea por línea
    while ((bytesRead = GARLIC_fread(buffer, 1, sizeof(buffer) - 1, f)) > 0) {
        buffer[bytesRead] = '\0';  // Asegurar terminación de cadena
        GARLIC_printf("%s", buffer);  // Mostrar la línea
    }

    GARLIC_printf("\n=== Fin del archivo ===\n");

    // Cerrar el archivo
    GARLIC_fclose(f);
    GARLIC_printf("-- Archivo cerrado --\n");

    return 0;
}
