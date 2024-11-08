#include <GARLIC_API.h>  

int _start() {
    char *filename = "/Datos/testfile.txt";  // Nombre del archivo a abrir
    GARLIC_FILE *file;                // Puntero de archivo de tipo GARLIC_FILE*
    unsigned int bytesRead;
    char buffer[128];                 // Buffer para leer datos del archivo

    // Intentar abrir el archivo en modo lectura
    file = GARLIC_fopen(filename, "r");
    if (file == (void*)0) {           // Usamos (void*)0 en lugar de NULL
        GARLIC_printf("Error: No se pudo abrir el archivo %s para lectura.\n", filename);
        return 1;  // Terminar con error si no se pudo abrir
    }

    GARLIC_printf("Archivo %s abierto correctamente para lectura.\n", filename);

    // Leer y procesar el archivo
    while ((bytesRead = GARLIC_fread(buffer, 1, sizeof(buffer), file)) > 0) {
        // Procesa los datos leídos en buffer, si es necesario
        GARLIC_printf("Se leyeron %u bytes del archivo.\n", bytesRead);
    }

    // Intentar cerrar el archivo
    if (GARLIC_fclose(file) != 0) {
        GARLIC_printf("Error: No se pudo cerrar el archivo %s.\n", filename);
        return 1;  // Terminar con error si no se pudo cerrar
    }

    GARLIC_printf("Archivo %s cerrado correctamente.\n", filename);

    return 0;  // Terminar exitosamente
}
