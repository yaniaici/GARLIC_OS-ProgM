/*------------------------------------------------------------------------------

	"garlic_mem.c" : fase 1 / programador M

	Funciones de carga de un fichero ejecutable en formato ELF, para GARLIC 1.0

------------------------------------------------------------------------------*/
#include <nds.h>
#include <filesystem.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "garlic_system.h"  // Definición de funciones y variables de sistema


#define INI_MEM 0x01002000   // Dirección inicial de memoria para programas
#define EI_NIDENT 16
#define PT_LOAD 1            // Definir PT_LOAD para los segmentos cargables
unsigned int first_pos = INI_MEM;  // Posición inicial en memoria para la carga

// Definici�n de tipos para ELF
typedef unsigned int Elf32_Addr;
typedef unsigned short Elf32_Half;
typedef unsigned int Elf32_Off;
typedef signed int Elf32_Sword;
typedef unsigned int Elf32_Word;

typedef struct {
    unsigned char e_ident[EI_NIDENT];
    Elf32_Half e_type;
    Elf32_Half e_machine;
    Elf32_Word e_version;
    Elf32_Addr e_entry;
    Elf32_Off e_phoff;
    Elf32_Off e_shoff;   // Offset de la tabla de secciones
    Elf32_Word e_flags;
    Elf32_Half e_ehsize;  
    Elf32_Half e_phentsize;
    Elf32_Half e_phnum;
    Elf32_Half e_shentsize;
    Elf32_Half e_shnum;   // Número de secciones
    Elf32_Half e_shstrndx;
} Elf32_Ehdr;

typedef struct {
    Elf32_Word p_type;
    Elf32_Off p_offset;
    Elf32_Addr p_vaddr;
    Elf32_Addr p_paddr;
    Elf32_Word p_filesz;
    Elf32_Word p_memsz;
    Elf32_Word p_flags;
    Elf32_Word p_align;
} Elf32_Phdr;

/* _gm_initFS: inicializa el sistema de ficheros, devolviendo un valor booleano
    para indicar si dicha inicializaci�n ha tenido �xito
*/
int _gm_initFS() {
    return nitroFSInit(NULL);
}

/* _gm_cargarPrograma: busca un fichero de nombre "(keyName).elf" dentro del
    directorio "/Programas/" del sistema de ficheros y carga los segmentos
    de programa a partir de una posición de memoria libre. Efectúa la reubicación
    de las referencias a los símbolos del programa según el desplazamiento
    del código en la memoria destino.

    Parámetros:
        keyName -> string de 4 caracteres con el nombre en clave del programa
    Resultado:
        != 0 -> dirección de inicio del programa (intFunc)
        == 0 -> no se ha podido cargar el programa
*/
intFunc _gm_cargarPrograma(char *keyName) {
    FILE *fit = NULL;
	// Variables para tratar el archivo ELF
    Elf32_Ehdr header;
    Elf32_Phdr segTable;
    Elf32_Addr entry;
    Elf32_Off segOffset;
	Elf32_Half numSegments;  // Número de segmentos
    char path[32];  // Ruta del fichero ELF
    int startAddress = 0;  // Dirección de inicio del programa cargado
    char *pFitxer;  // Puntero al contenido del fichero ELF
    int fit_size = 0;  // Tamaño del fichero
    

    // Construcción de la ruta del fichero ELF
    sprintf(path, "/Programas/%s.elf", keyName);

    // Abrir el fichero en modo lectura binaria
    fit = fopen(path, "rb");
    if (fit == NULL) {
        perror("Error abriendo el fichero ELF");
        return (intFunc)0;
    }

    // Obtener el tamaño del fichero
    fseek(fit, 0, SEEK_END);
    fit_size = ftell(fit);
    fseek(fit, 0, SEEK_SET);

    // Verificar si el tamaño es valido
    if (fit_size < sizeof(Elf32_Ehdr)) {
        perror("Tamaño del archivo ELF demasiado pequeño");
        fclose(fit);
        return (intFunc)0;
    }

    // Reservar memoria para el contenido del fichero
    pFitxer = (char *)malloc(sizeof(char) * fit_size);
    if (pFitxer == NULL) {
        perror("Error al reservar memoria para el fichero ELF");
        fclose(fit);
        return (intFunc)0;
    }

    // Leer el contenido del fichero en memoria
    if (fread(pFitxer, 1, fit_size, fit) != fit_size) {
        perror("Error leyendo el fichero ELF");
        free(pFitxer);
        fclose(fit);
        return (intFunc)0;
    } else {
	printf("Encabezado ELF leido"); 
	}

    // Leer el encabezado ELF directamente desde el fichero
    fseek(fit, 0, SEEK_SET);
    fread(&header, sizeof(Elf32_Ehdr), 1, fit);

    // Guardar en variables locales para evitar accesos repetidos
    numSegments = header.e_phnum;  // Número de segmentos
    entry = header.e_entry;        // Dirección de entrada del programa
    segOffset = header.e_phoff;    // Offset de la tabla de segmentos
	
	printf("Número de segmentos: %u\n", numSegments);
    printf("Dirección de entrada: 0x%08X\n", entry);
    printf("Offset de la tabla de segmentos: 0x%08X\n", segOffset); 

    // Iterar sobre los segmentos del ELF
    for (int i = 0; i < numSegments; i++) {
        // Mover el puntero del fichero al segmento actual
        fseek(fit, segOffset, SEEK_SET);

        // Leer el segmento actual directamente desde el fichero
        fread(&segTable, sizeof(Elf32_Phdr), 1, fit);

        // Procesar solo los segmentos de tipo PT_LOAD (cargables)
        if (segTable.p_type == PT_LOAD) {
            // Copiar el segmento en la memoria destino
            _gs_copiaMem((const void *)(pFitxer + segTable.p_offset), (void *)first_pos, segTable.p_filesz);

            // Realizar la reubicación de símbolos
            _gm_reubicar(pFitxer, segTable.p_paddr, (unsigned int *)first_pos);
			
            // Alinear el tamaño del segmento a 4 bytes si es necesario
            int padding = segTable.p_memsz % 4;
            if (padding != 0) {
                segTable.p_memsz += (4 - padding);
            }

            // Calcular la dirección de inicio del programa cargado
            startAddress = entry - segTable.p_vaddr + first_pos;

            // Actualizar la primera posición libre en memoria
            first_pos += segTable.p_memsz;
        }

        // Actualizar el offset para el siguiente segmento
        segOffset += sizeof(Elf32_Phdr);
    }

    // Liberar memoria usada para el fichero ELF
    free(pFitxer);
    fclose(fit);

    // Retornar la dirección de inicio del programa cargado
    return (intFunc)startAddress;
}


