/*------------------------------------------------------------------------------

	"garlic_graf.c" : fase 1 / programador G

	Funciones de gesti�n del entorno gr�fico (ventanas de texto), para GARLIC 1.0

------------------------------------------------------------------------------*/
#include <nds.h>

#include "garlic_system.h"	// definici�n de funciones y variables de sistema
#include "garlic_font.h"	// definici�n gr�fica de caracteres

/* definiciones para realizar c�lculos relativos a la posici�n de los caracteres
	dentro de las ventanas gr�ficas, que pueden ser 4 o 16 */
#define NVENT	4				// n�mero de ventanas totales
#define PPART	2				// n�mero de ventanas horizontales o verticales
								// (particiones de pantalla)

#define VCOLS	32				// columnas y filas de cualquier ventana
#define VFILS	24
#define PCOLS	VCOLS * PPART	// n�mero de columnas totales (en pantalla)
#define PFILS	VFILS * PPART	// n�mero de filas totales (en pantalla)

int bg2, bg3, bg2map;


/* _gg_generarMarco: dibuja el marco de la ventana que se indica por par�metro */
void _gg_generarMarco(int v)
{
    // Obtenemos el puntero al mapa de memoria del fondo gr�fico 3 (bg3). 
    // El c�lculo del desplazamiento para la ventana v se hace dividiendo v por el n�mero de particiones horizontales (PPART),
    // multiplicando por el n�mero de filas por ventana (VFILS), ajustado por el tama�o de la ventana y columnas (VCOLS * 2).
    u16 * mapPtr = bgGetMapPtr(bg3) + (((v) / PPART) * VFILS * 2 * VCOLS);

    // Si la ventana v est� en una posici�n impar (en la parte derecha de la pantalla):
    // Ajustamos el puntero sumando el n�mero de columnas (VCOLS) multiplicado por la partici�n horizontal de la ventana (v % PPART).
    if (v % PPART != 0) {
        mapPtr += VCOLS * (v % PPART);
    }

    // Iteramos a trav�s de las filas de la ventana (de 0 a VFILS - 1), donde cada fila es una l�nea de 8x8 bloques de caracteres gr�ficos.
    for (int i = 0; i < VFILS; i++) {
        // Dentro de cada fila, iteramos sobre las columnas de la ventana (de 0 a VCOLS - 1).
        for (int j = 0; j < VCOLS; j++) {
            // Calculamos la posici�n en el mapa de memoria del fondo 3 para la celda (i, j).
            // Multiplicamos la fila (i) por 64, el n�mero total de columnas del mapa de caracteres, y le sumamos la columna actual (j).
            int pos = j + i * 64;

            // Si estamos en la primera fila (i == 0), dibujamos el borde superior de la ventana:
            if (i == 0) {
                // Si estamos en la primera columna (j == 0), dibujamos la esquina superior izquierda (car�cter 103).
                // Si estamos en la �ltima columna (j == VCOLS - 1), dibujamos la esquina superior derecha (car�cter 102).
                // Si estamos en cualquier otra columna, dibujamos el borde superior (car�cter 99).
                mapPtr[pos] = (j == 0) ? 103 : (j == VCOLS - 1) ? 102 : 99;
            } 
            // Si estamos en la �ltima fila (i == VFILS - 1), dibujamos el borde inferior de la ventana:
            else if (i == VFILS - 1) {
                // Si estamos en la primera columna (j == 0), dibujamos la esquina inferior izquierda (car�cter 100).
                // Si estamos en la �ltima columna (j == VCOLS - 1), dibujamos la esquina inferior derecha (car�cter 101).
                // Si estamos en cualquier otra columna, dibujamos el borde inferior (car�cter 97).
                mapPtr[pos] = (j == 0) ? 100 : (j == VCOLS - 1) ? 101 : 97;
            } 
            // Si estamos en cualquier fila intermedia (ni la primera ni la �ltima):
            else {
                // Si estamos en la primera columna (j == 0), dibujamos el borde izquierdo (car�cter 96).
                // Si estamos en la �ltima columna (j == VCOLS - 1), dibujamos el borde derecho (car�cter 98).
                // En el resto de columnas intermedias, no hacemos nada, ya que el marco solo afecta a los bordes.
                mapPtr[pos] = (j == 0) ? 96 : (j == VCOLS - 1) ? 98 : mapPtr[pos];
            }
        }
    }
}



/* _gg_iniGraf: inicializa el procesador gr�fico A para GARLIC 1.0 */
void _gg_iniGrafA()
{
    // Configura el modo gr�fico principal en modo 5 (512x512 Extended Rotation).
    videoSetMode(MODE_5_2D);   // Modo 2D para fondos gr�ficos.
    
    // Configura la pantalla principal de la NDS (pantalla superior).
    lcdMainOnTop();
    
    // Reserva el banco de memoria VRAM para los fondos gr�ficos.
    vramSetBankA(VRAM_A_MAIN_BG_0x06000000);

    // Cada mapa de fondo ocupa 8192 bytes en la memoria VRAM (64x64 tiles, 512x512 p�xeles).
    // Los bg2 y bg3 comparten las mismas baldosas, por lo que utilizamos la misma base de tiles.
	
    // Inicializa el bg2 en modo de rotaci�n extendida con un tama�o de 512x512 p�xeles.
    // bgInit() devuelve un �ndice de fondo que se utilizar� para referenciarlo.
    bg2 = bgInit(2, BgType_ExRotation, BgSize_ER_512x512, 2, 4);
    
    // Inicializa el bg3 tambi�n en modo de rotaci�n extendida y 512x512 p�xeles.
    bg3 = bgInit(3, BgType_ExRotation, BgSize_ER_512x512, 8, 4);

    // Obtiene el puntero al mapa de memoria del bg2, que se usar� m�s adelante.
    bg2map = (int) bgGetMapPtr(bg2);

    // Establece la prioridad del bg2 en 1 y la del bg3 en 0 (bg3 tendr� m�s prioridad).
    // Los valores de prioridad van de 0 (m�s alta) a 3 (m�s baja).
    bgSetPriority(bg3, 0);
    bgSetPriority(bg2, 1);

    // Descomprime la fuente de letras (almacenada en formato LZ77) en la memoria de tiles del bg3.
    decompress(garlic_fontTiles, bgGetGfxPtr(bg3), LZ77Vram);

    /* Los gr�ficos de las fuentes de letras se almacenan en la memoria de tiles del bg3.
       Esto es eficiente porque los bg2 y bg3 comparten los mismos gr�ficos (tiles).
    */

    // Copia la paleta de colores de las fuentes a la memoria de la paleta principal.
    // La paleta comienza en la direcci�n 0x05000000.
    dmaCopy(garlic_fontPal, BG_PALETTE, sizeof(garlic_fontPal));

    // Genera los marcos de las ventanas de texto para las NVENT ventanas.
    for (int i = 0; i < NVENT; i++) {
        _gg_generarMarco(i);  // Dibuja los marcos en el bg3.
    }

    // Escala los bg2 y bg3 para que se ajusten al tama�o de la pantalla de la NDS (256x192 p�xeles).
    // La escala es de 50%.
    bgSetScale(bg2, 512, 512);  // Ajusta la escala del bg2.
    bgSetScale(bg3, 512, 512);  // Ajusta la escala del bg3.

    // Actualiza la configuraci�n de los fondos.
    bgUpdate();
}

/* _gg_procesarFormato: copia los caracteres del string de formato sobre el
					  string resultante, pero identifica los c digos de formato
					  precedidos por '%' e inserta la representaci�n ASCII de
					  los valores indicados por par�metro.
	Par�metros:
		formato	->	string con c�digos de formato (ver descripci�n _gg_escribir);
		val1, val2	->	valores a transcribir, sean n�mero de c�digo ASCII (%c),
					un n�mero natural (%d, %x) o un puntero a string (%s);
		resultado	->	mensaje resultante.
	Observaci�n:
		Se supone que el string resultante tiene reservado espacio de memoria
		suficiente para albergar todo el mensaje, incluyendo los caracteres
		literales del formato y la transcripci�n a c�digo ASCII de los valores.
*/
void _gg_procesarFormato(char *formato, unsigned int val1, unsigned int val2, char *resultado) {
    char caract;                    // Variable para el car�cter actual en el string de formato
    int j = 0, i = 0, comptador, var = 2;  // j: �ndice de formato, i: �ndice de resultado
                                           // comptador: usado para recorrer strings y n�meros
                                           // var: controla si se est� usando val1 o val2
    char val[11];                   // Array temporal para almacenar valores convertidos (dec o hex)

    // Recorre el string de formato car�cter por car�cter
    while ((caract = formato[j]) != '\0') {
        // Si encontramos un '%', se espera un c�digo de formato
        if (caract == '%') {
            j++;                    // Avanzamos al siguiente car�cter que deber�a ser un c�digo
            caract = formato[j];

            // Si es un string (%s) y quedan variables por procesar
            if (caract == 's' && var > 0) {
                // Decidimos si usar val1 o val2 como string
                char *valor = (var == 2) ? (char *)val1 : (char *)val2;
                var--;               // Decrementamos var para usar el siguiente valor la pr�xima vez

                // Copiamos el string en el resultado
                comptador = 0;       // Inicializamos el �ndice del string que vamos a copiar
                while (valor[comptador] != '\0') {
                    resultado[i++] = valor[comptador++];  // Copia car�cter por car�cter
                }
                j++;                 // Avanzamos al siguiente car�cter en formato despu�s del c�digo %s
            }
            // Si es un car�cter ASCII (%c)
            else if (caract == 'c' && var > 0) {
                // Decidimos si usar val1 o val2 como car�cter
                resultado[i++] = (var == 2) ? (char)val1 : (char)val2;
                var--;               // Decrementamos var para usar el siguiente valor la pr�xima vez
                j++;                 // Avanzamos al siguiente car�cter en formato despu�s del c�digo %c
            }
            // Si es un n�mero decimal (%d)
            else if (caract == 'd' && var > 0) {
                // Convertimos el valor a string decimal usando _gs_num2str_dec
                if (var == 2) {
                    _gs_num2str_dec(val, sizeof(val), val1);
                } else {
                    _gs_num2str_dec(val, sizeof(val), val2);
                }
                var--;               // Decrementamos var para usar el siguiente valor la pr�xima vez

                // Copiamos el valor convertido al resultado, omitiendo espacios
                comptador = 0;
                while (val[comptador] != '\0') {
                    if (val[comptador] != ' ') {  // Saltamos espacios en blanco
                        resultado[i++] = val[comptador];
                    }
                    comptador++;      // Avanzamos en el valor convertido
                }
                j++;                 // Avanzamos al siguiente car�cter en formato despu�s del c�digo %d
            }
            // Si es un n�mero hexadecimal (%x)
            else if (caract == 'x' && var > 0) {
                // Convertimos el valor a string hexadecimal usando _gs_num2str_hex
                if (var == 2) {
                    _gs_num2str_hex(val, sizeof(val), val1);
                } else {
                    _gs_num2str_hex(val, sizeof(val), val2);
                }
                var--;               // Decrementamos var para usar el siguiente valor la pr�xima vez

                // Copiamos el valor hexadecimal convertido al resultado, omitiendo ceros iniciales
                comptador = 0;
                while (val[comptador] != '\0') {
                    if (val[comptador] != '0') {  // Saltamos ceros iniciales
                        resultado[i++] = val[comptador];
                    }
                    comptador++;      // Avanzamos en el valor convertido
                }
                j++;                 // Avanzamos al siguiente car�cter en formato despu�s del c�digo %x
            }
            // Si es un literal '%', o si no hay m�s variables que procesar
            else if (caract == '%' || var == 0) {
                resultado[i++] = '%'; // A�adimos un literal '%' al resultado
                if (var == 0) {       // Si no hay m�s variables, a�adimos el car�cter tal cual
                    resultado[i++] = caract;
                }
                j++;                 // Avanzamos al siguiente car�cter en formato despu�s del '%%'
            }
        } 
        // Si no es un car�cter de formato, copiamos el car�cter literal del formato al resultado
        else {
            resultado[i++] = formato[j++];
        }
    }
}

/* _gg_escribir: escribe una cadena de caracteres en la ventana indicada;
	Par metros:
		formato	->	cadena de formato, terminada con centinela '\0';
					admite '\n' (salto de l�nea), '\t' (tabulador, 4 espacios)
					y codigos entre 32 y 159 (los 32 �ltimos son caracteres
					graficos), adem�s de c�digos de formato %c, %d, %x y %s
					(max. 2 codigos por cadena)
		val1	->	valor a sustituir en primer c�digo de formato, si existe
		val2	->	valor a sustituir en segundo c�digo de formato, si existe
					- los valores pueden ser un c�digo ASCII (%c), un valor
					  natural de 32 bits (%d, %x) o un puntero a string (%s)
		ventana	->	numero de ventana (de 0 a 3)
*/
void _gg_escribir(char *formato, unsigned int val1, unsigned int val2, int ventana) {
    int numChars = 0;               // N�mero de caracteres actuales en la l�nea de la ventana
    int filaActual = 0;             // N�mero de la fila actual en la ventana
    int i = 0;                      // �ndice para recorrer el string procesado
    int esTabulador = 0;            // Flag para indicar si se est� procesando un tabulador
    char caracter;                  // Car�cter actual procesado
    char resultado[3 * VCOLS] = ""; // String resultante despu�s de procesar el formato

    // Procesar el formato y generar el string resultante en 'resultado'
    _gg_procesarFormato(formato, val1, val2, resultado);

    // Extraer el n�mero de caracteres y la fila actual del control de la ventana
    // pControl tiene dos partes: los 16 bits bajos son numChars y los 16 bits altos son filaActual
    numChars = _gd_wbfs[ventana].pControl & 0xFFFF;   // M�scara para obtener los bits bajos (numChars)
    filaActual = _gd_wbfs[ventana].pControl >> 16;    // Desplazar para obtener los bits altos (filaActual)

    // Procesar cada car�cter del string resultante
    while ((caracter = resultado[i]) != '\0') {
        // Si es un tabulador (\t), completar con espacios hasta el siguiente m�ltiplo de 4
        if (caracter == '\t') {
            esTabulador = (numChars % 4 == 0) ? 1 : 0;  // Verificar si est� alineado con m�ltiplo de 4
            while (((numChars < VCOLS) && (numChars % 4 != 0)) || esTabulador) {
                esTabulador = 0;                         // Solo entrar una vez si ya est� alineado
                _gd_wbfs[ventana].pChars[numChars++] = ' ';  // Insertar espacio en la posici�n actual
            }
        }
        // Procesar salto de l�nea (\n) o caracteres normales
        else {
            if (caracter != '\n' || numChars < VCOLS) {  // Si no es salto de l�nea o si no se llena la l�nea
                _gd_wbfs[ventana].pChars[numChars++] = caracter;  // A�adir el car�cter al buffer
            }
        }

        // Si es un salto de l�nea o se ha completado una l�nea completa en la ventana
        if (caracter == '\n' || numChars == VCOLS) {
            swiWaitForVBlank();  // Esperar a que el sistema est� en periodo de VBlank (sin dibujo en pantalla)

            // Si hemos llegado al final de las filas de la ventana, desplazamos el contenido
            if (filaActual == VFILS) {
                _gg_desplazar(ventana);  // Desplazar todo el contenido de la ventana hacia arriba
                filaActual--;            // Volver una fila hacia atr�s
            }

            // Escribir la l�nea actual en la ventana
            _gg_escribirLinea(ventana, filaActual, numChars);
            numChars = 0;  // Reiniciar el contador de caracteres para la siguiente l�nea
            filaActual++;  // Pasar a la siguiente fila
        }

        // Actualizar el control de la ventana: los 16 bits altos con filaActual y los 16 bits bajos con numChars
        _gd_wbfs[ventana].pControl = (filaActual << 16) + numChars;
        i++;  // Avanzar al siguiente car�cter en el string procesado
    }
}
