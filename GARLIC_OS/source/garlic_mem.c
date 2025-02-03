/*------------------------------------------------------------------------------

	"garlic_mem.c" : fase 2 / Yani Aici Lounis

	Funciones de carga de un fichero ejecutable en formato ELF, para GARLIC 2.0

------------------------------------------------------------------------------*/
#include <nds.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "garlic_system.h"

#define INI_MEM 0x01002000   // Dirección inicial de memoria para programas
#define EI_NIDENT 16         // Número de bytes del identificador ELF
#define PT_LOAD 1            // Tipo de segmento cargable
#define MAX_FILES 10
unsigned int first_pos = INI_MEM;  // Posición inicial en memoria para la carga

unsigned int ini_prog = INI_MEM;

// Definición de la cabecera ELF
typedef struct {
    unsigned char e_ident[16];    // Identificador del archivo ELF
    unsigned short e_type;        // Tipo del archivo ELF
    unsigned short e_machine;     // Tipo de arquitectura
    unsigned int e_version;       // Versión del ELF
    unsigned int e_entry;         // Dirección de entrada (inicio del programa)
    unsigned int e_phoff;         // Offset de la tabla de segmentos
    unsigned int e_shoff;         // Offset de la tabla de secciones
    unsigned int e_flags;         // Flags
    unsigned short e_ehsize;      // Tamaño de la cabecera ELF
    unsigned short e_phentsize;   // Tamaño de cada entrada de la tabla de segmentos
    unsigned short e_phnum;       // Número de entradas en la tabla de segmentos
    unsigned short e_shentsize;   // Tamaño de cada entrada de la tabla de secciones
    unsigned short e_shnum;       // Número de entradas en la tabla de secciones
    unsigned short e_shstrndx;    // Índice de la tabla de nombres de secciones
} Elf32_Ehdr;

// Definición de las entradas de la tabla de segmentos ELF
typedef struct {
    unsigned int p_type;          // Tipo del segmento
    unsigned int p_offset;        // Offset del segmento en el archivo
    unsigned int p_vaddr;         // Dirección virtual
    unsigned int p_paddr;         // Dirección física
    unsigned int p_filesz;        // Tamaño en el archivo
    unsigned int p_memsz;         // Tamaño en memoria
    unsigned int p_flags;         // Permisos del segmento
    unsigned int p_align;         // Alineación del segmento
} Elf32_Phdr;

#include <nds.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <filesystem.h>
#define DATA_PATH "/Datos/"  // Ruta donde se buscan los archivos originales

#define MAX_FILES 10       // Número máximo de archivos en el sistema
#define FILE_SIZE (64 * 1024) // Tamaño máximo de cada archivo (64 KB)

// Estructura para manejar archivos en memoria
typedef struct {
    char file_buffer[FILE_SIZE];  // Buffer en memoria del archivo
    char *ptr;                    // Puntero de lectura/escritura
    char opened;                   // Indicador de si el archivo está abierto
} FILE_GARLIC;

// Estructura del sistema de archivos
typedef struct {
    FILE_GARLIC files[MAX_FILES]; // Almacén de archivos
} t_filesystem;

t_filesystem filesystem;  // Instancia del sistema de archivos


/*------------------------------------------------------------------------
 * Función: initialize_filesystem
 * Descripción: Precarga los archivos "fileX" (X=0-9) desde "/Datos/" en memoria.
 * Si el archivo no existe, se inicializa vacío.
 *------------------------------------------------------------------------*/
void initialize_filesystem() {
    _gg_escribir("[DEBUG] Inicializando sistema de archivos en RAM...\n", 0, 0, 0);

    for (int i = 0; i < MAX_FILES; i++) {
        char filename[32];
        snprintf(filename, sizeof(filename), "%sfile%d", DATA_PATH, i);

        FILE *disk_file = fopen(filename, "rb");
        FILE_GARLIC *file = &filesystem.files[i];

        // Reiniciar buffer y estado del archivo
        memset(file->file_buffer, 0, FILE_SIZE);
        file->ptr = file->file_buffer;
        file->opened = 0; // Archivo cerrado por defecto

        if (disk_file) {
            fseek(disk_file, 0, SEEK_END);
            size_t file_size = ftell(disk_file);
            fseek(disk_file, 0, SEEK_SET);

            fread(file->file_buffer, 1, (file_size > FILE_SIZE) ? FILE_SIZE : file_size, disk_file);
            fclose(disk_file);

            _gg_escribir("[DEBUG] Archivo %s cargados en memoria (%d bytes)\n", (unsigned int)filename, file_size, 0);
        }
    }
}

/*------------------------------------------------------------------------
 * Función: GARLIC_fopen
 * Descripción: Abre un archivo en memoria con nombre "fileX" (X = 0-9).
 *------------------------------------------------------------------------*/
FILE_GARLIC *GARLIC_fopen(const char *filename, const char *mode) {
    if (strncmp(filename, "file", 4) != 0) return NULL;
    int index = filename[4] - '0';
    if (index < 0 || index >= MAX_FILES) return NULL;

    FILE_GARLIC *file = &filesystem.files[index];

    // Si el archivo no tiene contenido en memoria, significa que no fue cargado.
    if (file->file_buffer[0] == '\0') {
        _gg_escribir("[DEBUG] Archivo %s no encontrado en memoria\n", (unsigned int)filename, 0, 0);
        return NULL;  // Retornar antes de marcarlo como abierto
    }

    // Archivo encontrado en memoria, lo abrimos
    file->opened = 1;
    file->ptr = file->file_buffer; // Reiniciar puntero de lectura/escritura

    _gg_escribir("[DEBUG] Archivo %s abierto correctamente\n", (unsigned int)filename, 0, 0);
    return file;
}


/*------------------------------------------------------------------------
 * Función: GARLIC_fread
 * Descripción: Lee datos de un archivo en memoria.
 *------------------------------------------------------------------------*/
int GARLIC_fread(void *buffer, size_t size, size_t numele, FILE_GARLIC *file) {
    if (!file || !file->opened) return 0;

    size_t bytes_to_read = size * numele;

    // Si intenta leer más allá del archivo
    if (file->ptr + bytes_to_read > file->file_buffer + FILE_SIZE) {
        bytes_to_read = file->file_buffer + FILE_SIZE - file->ptr;
    }

    memcpy(buffer, file->ptr, bytes_to_read);
    file->ptr += bytes_to_read;
    return bytes_to_read;
}

/*------------------------------------------------------------------------
 * Función: GARLIC_fwrite
 * Descripción: Escribe datos en un archivo en memoria.
 *------------------------------------------------------------------------*/
size_t GARLIC_fwrite(const void *buffer, size_t size, size_t count, FILE_GARLIC *file) {
    if (!file || !file->opened) return 0;

    size_t bytes_to_write = size * count;
    if (file->ptr + bytes_to_write > file->file_buffer + FILE_SIZE) {
        bytes_to_write = file->file_buffer + FILE_SIZE - file->ptr; // Ajustar a límite
    }

    memcpy(file->ptr, buffer, bytes_to_write);
    file->ptr += bytes_to_write; // Mover el puntero de escritura

    return bytes_to_write / size;
}

/*------------------------------------------------------------------------
 * Función: GARLIC_fclose
 * Descripción: Cierra un archivo en memoria.
 *------------------------------------------------------------------------*/
void GARLIC_fclose(FILE_GARLIC *file) {
    if (!file) return;
    file->opened = 0;
}

/*------------------------------------------------------------------------
 * Función: _gm_initFS
 * Descripción: Inicializa NitroFS y precarga los archivos en memoria.
 *------------------------------------------------------------------------*/
int _gm_initFS() {
    _gg_escribir("[DEBUG] Inicializando NitroFS y sistema de archivos en RAM...\n", 0, 0, 0);
    
    if (!nitroFSInit(NULL)) {
        _gg_escribir("[ERROR] No se pudo inicializar NitroFS\n", 0, 0, 0);
        return 0;
    }

    initialize_filesystem();
    return 1;
}
/* _gm_listaProgs: devuelve una lista con los nombres en clave de todos
			los programas que se encuentran en el directorio "Programas".
			Se considera que un fichero es un programa si su nombre tiene
			8 caracteres y termina con ".elf"; se devuelven sólo los
			4 primeros caracteres de los programas (nombre en clave).
			El resultado es un vector de strings (paso por referencia) y
			el número de programas detectados.
*/
int _gm_listaProgs(char* progs[]) {
    DIR *dir;
    struct dirent *ent;
    int num_progs = 0;

    // Abrir el directorio "/Programas/"
    dir = opendir("/Programas/");
    if (!dir) {
        _gg_escribir("ERROR: No se pudo abrir el directorio /Programas/\n", 0, 0, 0);
        return 0; // Error al abrir el directorio
    }

    // Leer todos los ficheros en el directorio
    while ((ent = readdir(dir)) != NULL) {
        if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
            continue; // Ignorar entradas "." y ".."
        }
        if (strlen(ent->d_name) == 8 && strstr(ent->d_name, ".elf") != NULL) {
            // Si el archivo tiene 8 caracteres y termina en ".elf"
            progs[num_progs] = (char *)malloc(5); // Reservar memoria para el nombre clave
            if (!progs[num_progs]) {
                _gg_escribir("ERROR: No se pudo asignar memoria\n", 0, 0, 0);
                continue; // Error al asignar memoria
            }
            strncpy(progs[num_progs], ent->d_name, 4); // Copiar los 4 primeros caracteres
            progs[num_progs][4] = '\0'; // Agregar el terminador nulo
            num_progs++; // Incrementar el contador de programas
        }
    }
    closedir(dir); // Cerrar el directorio
    return num_progs; // Devolver el número de programas detectados
}

/* _gm_cargarPrograma: busca un fichero de nombre "(keyName).elf" dentro del
					directorio "/Programas/" del sistema de ficheros y carga
					los segmentos de programa a partir de una posición de
					memoria libre, efectuando la reubicación de las referencias
					a los símbolos del programa según el desplazamiento del
					código y los datos en la memoria destino;
	Parámetros:
		zocalo	->	índice del zócalo que indexará el proceso del programa
		keyName ->	string de 4 caracteres con el nombre en clave del programa
	Resultado:
		!= 0	->	dirección de inicio del programa (intFunc)
		== 0	->	no se ha podido cargar el programa
*/
intFunc _gm_cargarPrograma(int zocalo, char *keyName) {
    FILE *fit;
    char path[32];
    snprintf(path, sizeof(path), "/Programas/%s.elf", keyName); // Construir la ruta del archivo

    // Abrir el fichero ELF
    fit = fopen(path, "rb");
    if (!fit) {
        _gg_escribir("ERROR: No se pudo abrir el fichero ELF %s\n", (unsigned int)path, 0, 0);
        return 0; // Error al abrir el archivo
    }

    // Leer el tamaño del fichero
    fseek(fit, 0, SEEK_END);
    long file_size = ftell(fit);
    fseek(fit, 0, SEEK_SET);

    // Verificar que el archivo sea suficientemente grande
    if (file_size < sizeof(Elf32_Ehdr)) {
        _gg_escribir("ERROR: Archivo ELF %s demasiado pequeño\n", (unsigned int)path, 0, 0);
        fclose(fit);
        return 0;
    }

    // Reservar memoria para el contenido del archivo
    char *file_buf = (char *)malloc(file_size);
    if (!file_buf) {
        _gg_escribir("ERROR: No se pudo reservar memoria\n", 0, 0, 0);
        fclose(fit);
        return 0;
    }

    // Leer el contenido del archivo en el buffer
    fread(file_buf, 1, file_size, fit);
    fclose(fit);

    // Verificar que el archivo sea un ELF válido
    Elf32_Ehdr *header = (Elf32_Ehdr *)file_buf;
    if (header->e_ident[0] != 0x7F || header->e_ident[1] != 'E' ||
        header->e_ident[2] != 'L' || header->e_ident[3] != 'F') {
        _gg_escribir("ERROR: Archivo %s no es un ELF válido\n", (unsigned int)path, 0, 0);
        free(file_buf);
        return 0;
    }

    // Procesar la tabla de segmentos
    Elf32_Phdr *ph_table = (Elf32_Phdr *)(file_buf + header->e_phoff);
    unsigned int *dest_code = NULL, *dest_data = NULL;
    intFunc start_address = 0;

    for (int i = 0; i < header->e_phnum; i++) {
        Elf32_Phdr *ph = &ph_table[i];
        if (ph->p_type != PT_LOAD) continue; // Solo procesar segmentos cargables

        // Reservar memoria para el segmento
        unsigned int *dest = _gm_reservarMem(zocalo, ph->p_memsz, (ph->p_flags == 5 ? 0 : 1));
        if (!dest) {
            _gg_escribir("ERROR: No se pudo reservar memoria para segmento %d\n", i, 0, 0);
            _gm_liberarMem(zocalo); // Liberar todas las franjas asignadas
            free(file_buf);
            return 0;
        }

        // Identificar y asignar segmento de código o datos
        if (ph->p_flags == 5) {
            dest_code = dest;
            start_address = (intFunc)(header->e_entry - ph->p_vaddr + (unsigned int)dest_code);
        } else {
            dest_data = dest;
        }

        // Copiar el contenido del segmento desde el archivo a la memoria
        memcpy(dest, file_buf + ph->p_offset, ph->p_filesz);

        // Ajustar alineación del segmento en memoria
        unsigned int padding = ph->p_memsz % 4;
        if (padding != 0) {
            ph->p_memsz += (4 - padding);
        }
    }

    // Verificar que se haya cargado el segmento de código
    if (!dest_code) {
        _gg_escribir("ERROR: No se pudo cargar el segmento de código\n", 0, 0, 0);
        _gm_liberarMem(zocalo);
        free(file_buf);
        return 0;
    }

    // Realizar reubicación de las referencias
    if (dest_code) {
        _gm_reubicar(file_buf, ph_table[0].p_paddr, dest_code,
                     dest_data ? ph_table[1].p_paddr : 0, dest_data);
    }

    free(file_buf); // Liberar el buffer del archivo
    return start_address; // Retornar la dirección de inicio del programa
}
