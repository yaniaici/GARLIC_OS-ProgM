/*------------------------------------------------------------------------------

	"GARLIC_API.h" : cabeceras de funciones del API (Application Program
					Interface) del sistema operativo GARLIC 1.0 (código fuente
					disponible en "GARLIC_API.s")

------------------------------------------------------------------------------*/
#ifndef _GARLIC_API_h_
#define _GARLIC_API_h_

// Definici�n de la estructura GARLIC_FILE
typedef struct {
    void *fileHandle;    // Puntero al manejador de archivo del sistema
    char mode;            // Modo de apertura 
} GARLIC_FILE;


	/* GARLIC_pid: devuelve el identificador del proceso actual */
extern int GARLIC_pid();


	/* GARLIC_random: devuelve un número aleatorio de 32 bits */
extern int GARLIC_random();


	/* GARLIC_divmod: calcula la divisi�n num / den (numerador / denominador),
		almacenando el cociente y el resto en las posiciones de memoria indica-
		das por *quo y *mod, respectivamente (pasa resultados por referencia);
		la función devuelve 0 si la divisi�n es correcta, o diferente de 0
		si hay algún problema (divisi�n por cero).
		ATENCI�N: solo procesa n�meros naturales de 32 bits SIN signo. */
extern int GARLIC_divmod(unsigned int num, unsigned int den,
							unsigned int * quo, unsigned int * mod);


	/* GARLIC_divmodL: calcula la división num / den (numerador / denominador),
		almacenando el cociente y el resto en las posiciones de memoria indica-
		das por *quo y *mod, respectivamente; los par�metros y los resultados
		se pasan por referencia; el numerador y el cociente son de tipo
		long long (64 bits), mientras que el denominador y el resto son de tipo
		unsigned int (32 bits sin signo).
		la función devuelve 0 si la división es correcta, o diferente de 0
		si hay algún problema (divisi�n por cero). */
extern int GARLIC_divmodL(long long * num, unsigned int * den,
							long long * quo, unsigned int * mod);


	/* GARLIC_printf: escribe un string en la ventana del proceso actual,
		utilizando el string de formato 'format' que se pasa como primer
		par�metro, insertando los valores que se pasan en los siguientes
		par�metros (hasta 2) en la posición y forma (tipo) que se especifique
		con los marcadores incrustados en el string de formato:
			%c	: inserta un car�cter (según cúdigo ASCII)
			%d	: inserta un natural (32 bits) en formato decimal
			%x	: inserta un natural (32 bits) en formato hexadecimal
			%s	: inserta un string
			%%	: inserta un car�cter '%' literal
		Adem�s, tambi�n procesa los metacar�cteres '\t' (tabulador) y '\n'
		(salto de l�nia). */
extern void GARLIC_printf(char * format, ...);

	// Define un nuevo car�cter gr�fico en el rango de 128 a 255
extern void GARLIC_setChar(unsigned char n, unsigned char *buffer);


extern GARLIC_FILE* GARLIC_fopen(const char *filename, const char *mode);

extern int GARLIC_fclose(GARLIC_FILE * file);

int GARLIC_fread(void * buffer, unsigned int size, unsigned int numele, GARLIC_FILE * file);

#endif // _GARLIC_API_h_
