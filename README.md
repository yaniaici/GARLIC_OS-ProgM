# GarlicOS - Fase 1 🚀

GarlicOS es un sistema operativo para Nintendo DS que implementa un **sistema de archivos en memoria RAM**. En la **Fase 2**, se ha desarrollado un sistema de ficheros propio basado en **memoria dinámica (heap)**, permitiendo la gestión de archivos sin acceso a disco.

---

## 📌 **Descripción del Proyecto**
### ✅ Características principales:
- **Sistema de archivos en RAM** (no se reflejan cambios en disco).
- **Soporta hasta 10 archivos** (`file0` a `file9`).
- **Precarga archivos** desde `/Datos/` si existen.
- **Cada archivo tiene un máximo de 64 KB**.
- **Uso de puntero de lectura/escritura** para `GARLIC_fread()` y `GARLIC_fwrite()`.
- **No hay gestión de directorios** (solo archivos planos en RAM).

---

## 📂 **Estructura del Proyecto**
```
garlic_os/
│── include/
│   ├── GARLIC_API.h       # Definición de las funciones API de GarlicOS
│   ├── garlic_system.h    # Funciones del sistema GarlicOS
│── source/
│   ├── garlic_mem.c       # Implementación del sistema de archivos en memoria
│   ├── main.c             # Código principal para ejecutar y probar GarlicOS
│   ├── open.c             # Prueba de lectura de archivos
│   ├── test.c             # Prueba de escritura y verificación de cambios en RAM
│── build/
│── README.md              # Este documento 📄
│── Makefile               # Script de compilación
```

---

## 🛠 **Compilación e Instalación**
### 🔹 **Requisitos Previos**
- **DevkitPro** con **libnds** y **dslink** instalados.
- Compilador **arm-none-eabi-gcc**.
- Acceso a un emulador de **Nintendo DS** o una Nintendo DS real.

### 🔹 **Compilar el Proyecto**
Ejecuta el siguiente comando en la terminal dentro del directorio del proyecto:

```sh
make
```

### 🔹 **Ejecutar en un Emulador**
Si usas **No$GBA** o **Desmume**, puedes cargar el `.nds` generado con:

```sh
nds-run garlic_os.nds
```

Si tienes una tarjeta flash en una Nintendo DS real:

1. Copia `garlic_os.nds` a la SD.
2. Ejecuta desde el menú de la tarjeta.

---

## 🚀 **Uso de las Funciones de Archivos en RAM**
### **1️⃣ Abrir un Archivo**
```c
FILE_GARLIC *file = GARLIC_fopen("file0", "r");
if (!file) {
    GARLIC_printf("Error al abrir el archivo\n");
}
```

### **2️⃣ Leer el Contenido de un Archivo**
```c
char buffer[128];
int bytes_read = GARLIC_fread(buffer, 1, sizeof(buffer) - 1, file);
buffer[bytes_read] = '\0';  // Asegurar terminación de cadena
GARLIC_printf("%s", buffer);
```

### **3️⃣ Escribir en un Archivo**
```c
char *texto = "Escribiendo en la RAM...\n";
GARLIC_fwrite(texto, 1, 25, file);
```

### **4️⃣ Cerrar un Archivo**
```c
GARLIC_fclose(file);
```

---

## 📌 **Tests Incluidos**
### 📝 **Test de Lectura (`open.c`)**
- Abre `"file0"`, lee el contenido y lo muestra en pantalla.

### 📝 **Test de Escritura (`test.c`)**
1. **Lee el archivo** y muestra su contenido.
2. **Escribe un mensaje** en `"file0"`.
3. **Vuelve a leer y mostrar el contenido**.
4. Confirma que `GARLIC_fwrite()` afecta la RAM pero **no persiste en disco**.

Ejemplo de salida esperada:
```
---------------
Contenido antes de escribir:
Hola mundo!

Escribiendo en la RAM...

---------------
Contenido después de escribir:
Hola mundo!
Escribiendo en la RAM...
---------------
```

---

## ⚠ **Notas Importantes**
- **No se gestionan directorios**, solo archivos planos.
- **No hay persistencia en el disco**: todo ocurre en RAM.
- **El tamaño máximo de un archivo es de 64 KB**.
- **Los cambios hechos con `GARLIC_fwrite()` solo existen en RAM**.

---

## 📜 **Licencia**
Este proyecto es solo con fines educativos y está basado en la arquitectura de **GarlicOS** para la Nintendo DS.
