#include <GARLIC_API.h>

int _start(int arg) {
    int velocidad_inicial = 0;  // Velocidad inicial en unidades por segundo
    int aceleracion = 10;       // Aceleración constante en unidades por segundo^2
    int tiempo_ms = 5000;       // Tiempo total en milisegundos
    int tiempo_seg = tiempo_ms / 1000; // Tiempo total en segundos
    int velocidad_intermedia;   // Velocidad en un momento dado
    int posicion_intermedia;    // Posición en un momento dado
    
    GARLIC_printf("Simulación de posición y velocidad:\n");
    GARLIC_printf("Tiempo total: %d segundos\n", tiempo_seg);

    // Bucle para calcular y mostrar resultados intermedios
    for (int t = 0; t <= tiempo_seg; t++) {
        // Calcular velocidad intermedia: v = vi + a * t
        velocidad_intermedia = velocidad_inicial + (aceleracion * t);
        
        // Calcular posición intermedia: x = vi * t + (1/2) * a * t^2
        posicion_intermedia = (velocidad_inicial * t) + ((aceleracion * t * t) / 2);

        // Imprimir resultados intermedios
        GARLIC_printf("Tiempo: %d segundos\n", t);
        GARLIC_printf("  Velocidad: %d unidades/segundo\n", velocidad_intermedia);
        GARLIC_printf("  Posición: %d unidades\n", posicion_intermedia);
    }

    // Imprimir resultados finales
    GARLIC_printf("Cálculos completados.\n");
    return 0;
}
