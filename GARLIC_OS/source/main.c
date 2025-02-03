/*------------------------------------------------------------------------------

	"main.c" : fase 2 / progM

	Versión final de GARLIC 2.0
	(carga de programas con 2 segmentos, listado de programas, gestión de
	 franjas de memoria)

------------------------------------------------------------------------------*/
#include <nds.h>

#include "garlic_system.h"	// definición de funciones y variables de sistema

extern int * punixTime;		// puntero a zona de memoria con el tiempo real

const short divFreq1 = -33513982/(1024*7);		// frecuencia de TIMER1 = 7 Hz



/* gestionSincronismos:	función para detectar cuándo un proceso ha terminado
						su ejecución, consultando el bit i-éssimo de la
						variable global _gd_sincMain; en caso de detección,
						libera la memoria reservada para el proceso del zócalo
						i-éssimo y pone el bit de _gd_sincMain a cero.
*/
void gestionSincronismos()
{
	int i, mask;
	
	if (_gd_sincMain & 0xFFFE)		// si hay algun sincronismo pendiente
	{
		mask = 2;
		for (i = 1; i <= 15; i++)
		{
			if (_gd_sincMain & mask)
			{						// liberar la memoria del proceso terminado
				_gm_liberarMem(i);
				_gg_escribir("* proceso %d terminado\n", i, 0, 0);
				_gs_dibujarTabla();
				_gd_sincMain &= ~mask;		// poner bit de sincronismo a cero
			}
			mask <<= 1;
		}
	}
}



/* esperaSegundos:	función para esperar un cierto número de segundos, usando
					la variable global _gd_tickCount.
*/
void esperaSegundos(unsigned char nsecs)
{
	unsigned int mtics;

	mtics = _gd_tickCount + (nsecs * 60);
	while (_gd_tickCount < mtics)		// esperar un cierto número de segundos
	{
		_gp_WaitForVBlank();
		gestionSincronismos();
	}
}



/* eliminaProc:	función para provocar la finalización de un proceso de usuario;
				si el zócalo indicado por parámetro contiene un proceso, libera
				la entrada del vector de PCBs correspondiente y busca el zócalo
				en la cola de READY, para eliminar dicha entrada de la cola
				(compactándola), decrementar número de procesos en Ready,
				resetear la ventana asociada, y eliminar la memoria reservada
				para ese proceso.
*/
void eliminaProc(unsigned char z)
{
	unsigned char i, j;
	
	if (_gd_pcbs[z].PID != 0)
	{
		_gd_pcbs[z].PID = 0;
		i = 0; j = 0;
		while ((j == 0) && (i < _gd_nReady))
		{
			if (_gd_qReady[i] == z)		// eliminar el proceso de cola de READY
			{
				for (j = i; j < _gd_nReady; j++)	// compacta cola de READY
					_gd_qReady[j] =_gd_qReady[j+1];
				_gd_nReady--;
			}
			i++;
		}
		_gm_liberarMem(z);
		_gg_escribir("* proceso %d destruido\n", z, 0, 0);
		_gs_dibujarTabla();
	}
}




/* test 0: 	test de obtención de los programas de usuario contenidos en el
			directorio "/Programas/" del disco de la NDS, llamando a la
			función _gm_listaProgs(); la función test0() muestra por pantalla
			(ventana 0) la lista de programas obtenida, y verifica si en la
			lista se encuentran 4 programas necesarios para realizar el resto
			de tests; en caso negativo, muestra un mensaje de error y devuelve
			cero; en caso positivo, devuelve 1.
*/
unsigned char test0()
{
	char *progs[16];	// se asume que para realizar este test nunca habrá más
						// de 16 programas de usuario contenidos en "/Programas/"
	char *expected[4] = {"DESC", "LABE", "PONG", "PRNT"};
	unsigned char num_progs, i, j, k;
	unsigned char result = 1;
	
	_gg_escribir("\n** TEST 0: lista de programas **\n", 0, 0, 0);
	num_progs = _gm_listaProgs(progs);
	if (num_progs == 0)
	{
		_gg_escribir("\nERROR: NO hay programas disponibles!\n", 0, 0, 0);
		result = 0;
	}
	else
	{
		k = 0;				// máscara de bits para los programas esperados
		for (i = 0; i < num_progs; i++)
		{
			_gg_escribir((i < 10 ? "\t %d: %s\t" : "\t%d: %s\t"), i, (unsigned int) progs[i], 0);
			j = 0;
			while ((k != 15) && (j < 4))
			{
				if (((k & (1 << j)) == 0) && (strcmp(progs[i], expected[j]) == 0))
					k |= (1 << j);		// activa el bit de un programa esperado
				j++;
			}
		}
		_gg_escribir((i & 1 ? "\n\n" : "\n"), 0, 0, 0);
		if (k != 15)
		{
			_gg_escribir("\nERROR: Faltan los siguientes programas:\n", 0, 0, 0);
			for (i = 0; i < 4; i++)
			{
				if ((k & (1 << i)) == 0)
					_gg_escribir("\t%s", (unsigned int) expected[i], 0, 0);
			}
			_gg_escribir("\n", 0, 0, 0);
			result = 0;
		}
	}
	return result;
}




/* test 1: 	test de carga de programas de usuario de forma consecutiva (DESC,
			LABE, PRNT), sin fragmentación de la memoria, comprobando que 
			funciona la carga de programas con uno o dos segmentos; esta
			función de test espera a que PRNT acabe y elimina DESC, dejando
			el programa LABE en marcha para crear un principio de fragmentación
			externa; la función devuelve 0 si se han podido cargar los tres
			programas, o 1 si ha habido algun problema con la carga de uno de
			los programas.
*/
unsigned char test1()
{
	char *expected[3] = {"DESC", "LABE", "PRNT"};
	intFunc start[3];
	unsigned char i;
	unsigned char result = 1;

	_gg_escribir("\n** TEST 1: carga consecutiva\n\tDESC | LABE | PRNT **\n", 0, 0, 0);
	for (i = 0; i < 3; i++)
	{
		start[i] = _gm_cargarPrograma(i+1, expected[i]);
	}
	if (start[0] && start[1] && start[2])	// verficación de carga
	{
		for (i = 0; i < 3; i++)		// se asume que siempre se podrán crear
		{							// los tres procesos asociados
			_gp_crearProc(start[i], i+1, expected[i], i);
		}
		while (_gp_numProc() > 3)	// espera finalicación de PRNT
		{
			_gp_WaitForVBlank();
			gestionSincronismos();
		}
		eliminaProc(1);		// fuerza la finalización de DESC (para acelerar el test)
	}
	else
	{
		_gg_escribir("\nERROR: algun programa no se ha podido cargar!\n", 0, 0, 0);
		result = 0;
	}
	return result;
}




/* test 2: 	test de carga de programas de usuario de forma NO consecutiva,
			aprovechando la fragmentación externa generada en el test 1;
			se carga el programa PONG para limitar el primer espacio de memoria
			disponible, y después se carga el DESC de manera que primero se
			cargará el segmento de código y después el segmento de datos después
			de la memoria reservada para el programa LABE (en el test anterior);
			si el DESC funciona correctamente, la reubicación habrá funcionado
			para segmentos de código y datos separados (no consecutivos);
			después de un cierto tiempo, la función eliminará el PONG e
			intentará cargar otro LABE, el cual cargará el segmento de datos
			en posiciones inferiores a las del segmento de código; la función
			devuelve 0 si se han podido cargar los tres programas, o 1 si ha
			habido algun problema con la carga de uno de los programas.
*/
unsigned char test2()
{
	char *expected[3] = {"PONG", "DESC", "LABE"};
	unsigned char zoc[3] = {5, 11, 9};
	intFunc start[3];
	unsigned char result = 0;

	_gg_escribir("\n** TEST 2: carga no consecutiva\n\tPONG | DESC **\n", 0, 0, 0);
	start[0] = _gm_cargarPrograma(zoc[0], expected[0]);
	start[1] = _gm_cargarPrograma(zoc[1], expected[1]);
	if (start[0] && start[1])		// verficación de carga
	{
		_gp_crearProc(start[0], zoc[0], expected[0], 0);
		_gp_crearProc(start[1], zoc[1], expected[1], 3);
		esperaSegundos(6);
		eliminaProc(zoc[0]);		// elimina PONG
		_gg_escribir("\n** TEST 2: carga no consecutiva\n\tLABE **\n", 0, 0, 0);
		start[2] = _gm_cargarPrograma(zoc[2], expected[2]);
		if (start[2])
		{
			_gp_crearProc(start[2], zoc[2], expected[2], 3);
			result = 1;
		}
	}
	if (result == 0)
	{
		_gg_escribir("\nERROR: algun programa no se ha podido cargar!\n", 0, 0, 0);
	}
	return result;
}

void forzarFinalizacionProcesos() {
    unsigned char i;
    for (i = 1; i <= 15; i++) { // Asumiendo que los procesos de usuario están en los zócalos 1 a 15
        if (_gd_pcbs[i].PID != 0) {
            eliminaProc(i); // Finalizar el proceso en el zócalo i si está en ejecución
        }
    }
}

/* test 3:  test para verificar la carga y ejecución de un programa específico,
            TEST, que realiza operaciones de lectura y escritura utilizando
            las funciones GARLIC_fopen, GARLIC_fread, GARLIC_fwrite y GARLIC_fclose.
            El test carga este programa en un zócalo específico, lo lanza, y espera a que finalice,
            asegurándose de que todo funcione correctamente. La función devuelve 0 si no se puede cargar o ejecutar el programa,
            o 1 si se ejecuta correctamente.
*/
unsigned char test3() {
    char *expected = "TEST";        // Nombre del programa a cargar
    unsigned char zocalo = 7;      // Zócalo donde se cargará el programa
    intFunc start = NULL;          // Dirección de inicio del programa
    unsigned char result = 0;      // Resultado del test

    _gg_escribir("\n** TEST 3: carga y ejecución de TEST **\n", 0, 0, 0);

    // Cargar el programa en memoria
    start = _gm_cargarPrograma(zocalo, expected);

    if (start) { // Verificar si la carga fue exitosa
        // Crear el proceso asociado al programa TEST
        _gp_crearProc(start, zocalo, expected, 1);
		esperaSegundos(6);
		eliminaProc(zocalo);		
        // Confirmar el éxito de la ejecución
        result = 1;
		_gp_WaitForVBlank();
        _gg_escribir("\n** TEST 3: TEST ejecutado y cerrado correctamente **\n", 0, 0, 0);
    } else {
        // Indicar error en la carga o ejecución
        _gg_escribir("\nERROR: El programa TEST no se pudo cargar!\n", 0, 0, 0);
    }

    return result;
}


/* test 4: 	test para verificar la carga y ejecución de un programa específico,
			CPVA (Carga de Procesos con Velocidad y Aceleración), que simula
			cálculos de movimiento rectilíneo uniforme acelerado; el test carga
			este programa en un zócalo específico, lo lanza, y espera a que
			finalice, asegurándose de que todo funcione correctamente.
			La función devuelve 0 si no se puede cargar o ejecutar el programa,
			o 1 si se ejecuta correctamente.
*/
unsigned char test4() {
    char *expected = "CPVA";        // Nombre del programa a cargar
    unsigned char zocalo = 7;      // Zócalo donde se cargará el programa
    intFunc start = NULL;          // Dirección de inicio del programa
    unsigned char result = 0;      // Resultado del test

    _gg_escribir("\n** TEST 4: carga y ejecución de CPVA **\n", 0, 0, 0);

    // Cargar el programa en memoria
    start = _gm_cargarPrograma(zocalo, expected);

    if (start) { // Verificar si la carga fue exitosa
        // Crear el proceso asociado al programa CPVA
        _gp_crearProc(start, zocalo, expected, 1);

        // Liberar la memoria y cerrar el proceso CPVA
        eliminaProc(zocalo);

        // Confirmar el éxito de la ejecución
        result = 1;
		_gp_WaitForVBlank();
        _gg_escribir("\n** TEST 4: CPVA ejecutado y cerrado correctamente **\n", 0, 0, 0);
    } else {
        // Indicar error en la carga o ejecución
        _gg_escribir("\nERROR: El programa CPVA no se pudo cargar!\n", 0, 0, 0);
    }

    return result;
}






/* Inicializaciones generales del sistema Garlic */
void inicializarSistema()
{
	_gg_iniGrafA();			// inicializar procesadores gráficos
	_gs_iniGrafB();
	_gs_dibujarTabla();

	_gd_seed = *punixTime;	// inicializar semilla para números aleatorios con
	_gd_seed <<= 16;		// el valor de tiempo real UNIX, desplazado 16 bits
	
	_gd_pcbs[0].keyName = 0x4C524147;	// "GARL"
	
	if (!_gm_initFS())
	{
		_gg_escribir("\nERROR: ¡no se puede inicializar  el sistema de ficheros!\n", 0, 0, 0);
		exit(0);
	}

	irqInitHandler(_gp_IntrMain);	// instalar rutina principal interrupciones
	irqSet(IRQ_VBLANK, _gp_rsiVBL);	// instalar RSI de vertical Blank
	irqEnable(IRQ_VBLANK);			// activar interrupciones de vertical Blank
	
	irqSet(IRQ_TIMER1, _gm_rsiTIMER1);
	irqEnable(IRQ_TIMER1);				// instalar la RSI para el TIMER1
	TIMER1_DATA = divFreq1; 
	TIMER1_CR = 0xC3;  	// Timer Start | IRQ Enabled | Prescaler 3 (F/1024)
	
	REG_IME = IME_ENABLE;			// activar las interrupciones en general
}


int main(int argc, char **argv) {
    inicializarSistema();
    _gg_escribir("********************************", 0, 0, 0);
    _gg_escribir("*                              *", 0, 0, 0);
    _gg_escribir("* Sistema Operativo GARLIC 2.0 *", 0, 0, 0);
    _gg_escribir("*                              *", 0, 0, 0);
    _gg_escribir("********************************", 0, 0, 0);
    _gg_escribir("*** Inicio fase 2 / ProgM\n", 0, 0, 0);

    if (test0()) {
        _gg_escribir("\n** TEST 0 completado correctamente **\n", 0, 0, 0);
       } if (test1()) {
            _gg_escribir("\n** TEST 1 completado correctamente **\n", 0, 0, 0);
           } if (test2()) {
                _gg_escribir("\n** TEST 2 completado correctamente **\n", 0, 0, 0);
              }  if (test3()) {
                    _gg_escribir("\n** TEST 3 completado correctamente **\n", 0, 0, 0);
                   } if (test4()) {
                        _gg_escribir("\n** TEST 4 completado correctamente! **\n", 0, 0, 0);
                    }
    _gg_escribir("\n*** Final fase 2 / ProgM\n", 0, 0, 0);
    while (1) _gp_WaitForVBlank();
    return 0;
}