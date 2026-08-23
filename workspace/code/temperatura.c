#include <stdio.h>

int main(void)
{
    int temperatura;
    const char *estado;

    if (scanf("%d", &temperatura) != 1)
    {
        fprintf(stderr, "Error: entrada invalida\n");
        return 1;
    }

    if (temperatura < 0)
    {
        estado = "congelacion";
    }
    else if (temperatura < 20)
    {
        estado = "frio";
    }
    else if (temperatura <= 30)
    {
        estado = "templado";
    }
    else
    {
        estado = "calor";
    }

    printf("Estado: %s\n", estado);
    return 0;
}
