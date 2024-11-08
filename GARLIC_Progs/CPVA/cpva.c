#include <GARLIC_API.h>  

int _start(int arg) {
    int velocidad_inicial = 0;  // velocidad inicial en unidades por segundo
    int aceleracion = 10;       // aceleración constante en unidades por segundo^2
    int tiempo_ms = 5000;       // tiempo en milisegundos
    int tiempo_seg;             // tiempo en segundos
    int velocidad_final;        // velocidad final en unidades por segundo
    int posicion;               // posición final en unidades
    
    // Convertir tiempo de milisegundos a segundos
    tiempo_seg = tiempo_ms / 1000;

    // Calcular velocidad final: vf = vi + a * t
    velocidad_final = velocidad_inicial + (aceleracion * tiempo_seg);

    // Calcular la posición final: x = vi * t + (1/2) * a * t^2
    // Nota: Para evitar flotantes, usamos aproximación en la parte de (1/2) * a * t^2.
    posicion = (velocidad_inicial * tiempo_seg) + ((aceleracion * tiempo_seg * tiempo_seg) / 2);

    // Imprimir resultados
    GARLIC_printf("Tiempo: %d segundos\n", tiempo_seg);
    GARLIC_printf("Velocidad final: %d unidades/segundo\n", velocidad_final);
    GARLIC_printf("Posición final: %d unidades\n", posicion);

    return 0;
}
