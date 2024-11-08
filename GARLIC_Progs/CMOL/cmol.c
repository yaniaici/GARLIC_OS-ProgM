#include <GARLIC_API.h>
#include <string.h> 

// Definimos una estructura para los elementos
typedef struct {
    char symbol[3];              // Símbolo químico del elemento
    int atomic_weight;           // Peso atómico del elemento en punto fijo (multiplicado por 10000)
} Element;

// Definimos una tabla periódica con algunos elementos y sus pesos atómicos (multiplicados por 10000)
Element periodic_table[] = {
    {"H", 10079}, {"He", 40026}, {"Li", 69410}, {"Be", 90122}, 
    {"B", 108110}, {"C", 120107}, {"N", 140067}, {"O", 159994},
    {"F", 189984}, {"Ne", 201797}, {"Na", 229897}, {"Mg", 243050},
    {"Al", 269815}, {"Si", 280855}, {"P", 309738}, {"S", 320650},
    {"Cl", 354530}, {"K", 390983}, {"Ar", 399480}, {"Ca", 400780},
    {"Sc", 449559}, {"Ti", 478670}, {"V", 509415}, {"Cr", 519961},
    {"Mn", 549380}, {"Fe", 558450}, {"Ni", 586934}, {"Co", 589332},
    {"Cu", 635460}, {"Zn", 653900}, {"Ga", 697230}, {"Ge", 726400},
    {"As", 749216}, {"Se", 789600}, {"Br", 799040}, {"Kr", 838000},
    {"Rb", 854678}, {"Sr", 876200}, {"Y", 889059}, {"Zr", 912240},
    {"Nb", 929064}, {"Mo", 959400}, {"Tc", 980000}, {"Ru", 1010700},
    {"Rh", 1029055}, {"Pd", 1064200}, {"Ag", 1078682}, {"Cd", 1124110},
    {"In", 1148180}, {"Sn", 1187100}, {"Sb", 1217600}, {"I", 1269045},
    {"Te", 1276000}, {"Xe", 1312930}, {"Cs", 1329055}, {"Ba", 1373270},
    {"La", 1389055}, {"Ce", 1401160}, {"Pr", 1409077}, {"Nd", 1442400},
    {"Pm", 1450000}, {"Sm", 1503600}, {"Eu", 1519640}, {"Gd", 1572500},
    {"Tb", 1589253}, {"Dy", 1625000}, {"Ho", 1649303}, {"Er", 1672590},
    {"Tm", 1689342}, {"Yb", 1730400}, {"Lu", 1749670}, {"Hf", 1784900},
    {"Ta", 1809479}, {"W", 1838400}, {"Re", 1862070}, {"Os", 1902300},
    {"Ir", 1922170}, {"Pt", 1950780}, {"Au", 1969665}, {"Hg", 2005900},
    {"Tl", 2043833}, {"Pb", 2072000}, {"Bi", 2089804}, {"Po", 2090000},
    {"At", 2100000}, {"Rn", 2220000}, {"Fr", 2230000}, {"Ra", 2260000},
    {"Ac", 2270000}, {"Pa", 2310359}, {"Th", 2320381}, {"Np", 2370000},
    {"U", 2380289}, {"Am", 2430000}, {"Pu", 2440000}, {"Cm", 2470000},
    {"Bk", 2470000}, {"Cf", 2510000}, {"Es", 2520000}, {"Fm", 2570000},
    {"Md", 2580000}, {"No", 2590000}, {"Rf", 2610000}, {"Lr", 2620000},
    {"Db", 2620000}, {"Bh", 2640000}, {"Sg", 2660000}, {"Mt", 2680000},
    {"Hs", 2770000}
};

// Función para imprimir un número en formato de coma fija con 4 decimales
void printComaFija(int num) {
    int integer_part = num / 10000;   // Parte entera del número
    int decimal_part = num % 10000;   // Parte decimal

    // Ajustar la impresión de la parte decimal para mantener cuatro dígitos de precisión
    GARLIC_printf("El peso molecular es: %d.%04d g/mol\n", integer_part, decimal_part);
}

// Función para obtener el peso atómico dado un símbolo de elemento
int get_atomic_weight(char symbol[]) {
    // Buscar el símbolo en la tabla periódica
    for (int i = 0; i < sizeof(periodic_table) / sizeof(Element); i++) {
        if (symbol[0] == periodic_table[i].symbol[0] && 
            (periodic_table[i].symbol[1] == symbol[1] || periodic_table[i].symbol[1] == '\0')) {
            return periodic_table[i].atomic_weight; // Retorna el peso en punto fijo
        }
    }
    return 0; // Si el elemento no es encontrado, devuelve 0
}

// Función para calcular el peso molecular a partir de una fórmula química
void _start(int arg) {
    int total_weight = 0;        // Peso molecular total acumulado
    char current_element[3] = {0}; // Almacena el símbolo del elemento actual
    int count = 0, i = 0;        // Contador de elementos y posición en fórmula
    const char *formula = "NaCl"; // Fórmula química a evaluar
	
    // Recorrer la fórmula química caracter por caracter
    while (formula[i] != '\0') {
        // Si es mayúscula, puede ser el comienzo de un nuevo elemento
        if (formula[i] >= 'A' && formula[i] <= 'Z') {
            // Si ya tenemos un elemento previo, agregar su peso total
            if (current_element[0] != '\0') {
                total_weight += get_atomic_weight(current_element) * (count > 0 ? count : 1);
            }
            // Empezamos a leer el nuevo elemento
            current_element[0] = formula[i];
            current_element[1] = '\0';  // Limpiamos el segundo carácter
            count = 0;  // Reiniciamos el contador
        }

        // Si es minúscula, lo agregamos al símbolo actual
        else if (formula[i] >= 'a' && formula[i] <= 'z') {
            current_element[1] = formula[i];
            current_element[2] = '\0';  // Terminamos la cadena
        }

        // Si es un número, actualizamos la cantidad del elemento
        else if (formula[i] >= '0' && formula[i] <= '9') {
            count = count * 10 + (formula[i] - '0'); // Convertimos el carácter a número
        }

        i++;
    }

    // Agregar el último elemento
    if (current_element[0] != '\0') {
        total_weight += get_atomic_weight(current_element) * (count > 0 ? count : 1);
    }
	
    printComaFija(total_weight); // Imprimir el peso molecular total calculado
}
