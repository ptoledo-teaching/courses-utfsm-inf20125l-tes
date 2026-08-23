# TES: Test cases y automatización de pruebas

## Introducción

Esta actividad presenta un flujo básico y reproducible para probar programas desde la terminal. El trabajo comienza con la ejecución manual de un programa y avanza hacia el uso de archivos de entrada, resultados esperados, comparación con `diff` y automatización mediante un script de Bash.

Un test case describe una situación concreta que se desea comprobar. En este laboratorio cada caso utiliza un archivo `.in` con la entrada y un archivo `.expected` con la salida esperada. Al ejecutar la prueba se genera un archivo `.out`, que se compara con el resultado esperado.

### Pre-requisitos

- Haber completado los laboratorios TER y VIM
- Saber navegar por directorios, inspeccionar archivos y modificar permisos
- Saber compilar programas en C con `gcc`
- Saber editar y guardar archivos con Vim
- Tener disponibles Bash, `gcc` y `diff`

### Objetivo general

- Construir y automatizar un flujo de pruebas basado en entradas y resultados esperados

### Objetivos específicos

- Comprender la estructura de un test case
- Observar y utilizar códigos de salida
- Entregar la entrada de un programa mediante `<`
- Guardar `stdout` y `stderr` mediante `>` y `2>`
- Comparar resultados con `diff`
- Distinguir entre una prueba exitosa, una prueba fallida y un error de ejecución
- Crear un caso de borde
- Ejecutar una suite de pruebas mediante un script de Bash

### Estructura inicial

```text
workspace/
├── code/
│   └── temperatura.c
├── tests/
│   ├── error.in
│   ├── test001.expected
│   ├── test001.in
│   ├── test002.expected
│   ├── test002.in
│   ├── test003.expected
│   └── test003.in
└── scripts/
    ├── check.sh
    └── tests-run.sh
```

Durante la actividad se generarán archivos `.out`, `.err` y `.diff`. También se crearán `test004.in` y `test004.expected`.

El script `check.sh` permite revisar el estado final. Comprueba el ejecutable, los casos de prueba, los permisos de los scripts y el resultado de la suite automatizada.

## Contexto

La Alianza Rebelde prepara una misión de reconocimiento en varios planetas de la galaxia. Antes de enviar un droide explorador, necesita comprobar que su sistema de clasificación térmica funcione correctamente: confundir el clima de Tatooine con el de Hoth podría arruinar la misión antes de comenzar.

El archivo `temperatura.c` representa el programa instalado en el droide. Recibe una temperatura entera obtenida por sus sensores y clasifica las condiciones de la superficie según la siguiente especificación:

| Temperatura | Salida |
| --- | --- |
| Menor que `0` | `Estado: congelacion` |
| Desde `0` hasta `19` | `Estado: frio` |
| Desde `20` hasta `29` | `Estado: templado` |
| `30` o mayor | `Estado: calor` |

Si el sensor entrega una lectura que no corresponde a un número entero, el programa escribe `Error: entrada invalida` en `stderr` y termina con un código distinto de cero.

El objetivo de la misión es construir un conjunto de test cases que permita comprobar el programa de forma repetible. Primero se realizarán pruebas manuales y luego se automatizará la suite completa, de modo que el software pueda verificarse rápidamente antes de cada despliegue del droide.

## Actividad

### 1. Preparar y observar el programa

#### 1.1. Inspeccionar el código y los archivos entregados

Desde la raíz del repositorio, entrar a `workspace`. Usar los comandos practicados anteriormente para inspeccionar el contenido de `code`, `tests` y `scripts`, y luego revisar `code/temperatura.c` sin modificarlo.

#### 1.2. Compilar y ejecutar manualmente

Construir el comando necesario para compilar `code/temperatura.c` con `-Wall`, `-Wextra`, `-Werror` y `-std=c11`. El ejecutable debe llamarse `temperatura` y quedar dentro de `code`.

Ejecutar el programa desde `workspace`, ingresar `25` y presionar `Enter`. La salida debe ser:

```text
Estado: templado
```

Repetir la ejecución con otros valores y comprobar que se cumpla la especificación.

#### 1.3. Observar el código de salida

Todo programa entrega un número al terminar. La shell conserva temporalmente ese valor en `$?`:

```bash
echo $?
```

El código debe consultarse inmediatamente después del comando que se quiere revisar. Ejecutar nuevamente `temperatura` con una entrada válida y comprobar que su código sea `0`.

Ejecutar el programa otra vez, ingresar `hola` y revisar de inmediato el nuevo código. El programa debe mostrar un mensaje de error y terminar con código `1`.

En este laboratorio se utilizará la siguiente convención:

- `0` indica que el programa terminó correctamente
- Un valor distinto de `0` indica que ocurrió un error durante la ejecución

### 2. Ejecutar el primer test case

#### 2.1. Reconocer sus componentes

Inspeccionar `tests/test001.in` y `tests/test001.expected`.

- `test001.in` contiene la entrada que recibirá el programa
- `test001.expected` contiene la salida que debería producir

Ambos archivos comparten el nombre `test001` porque pertenecen al mismo test case.

#### 2.2. Redirigir la entrada

El operador `<` hace que un programa lea su entrada desde un archivo:

```bash
./code/temperatura < tests/test001.in
```

La shell abre `test001.in` y lo entrega al programa como `stdin`. El programa no necesita saber que la entrada proviene de un archivo.

#### 2.3. Guardar la salida

El operador `>` guarda `stdout` en un archivo. Adaptar la ejecución anterior para crear `tests/test001.out`, que almacenará la salida obtenida durante la prueba.

El comando no debe mostrar el estado por pantalla, porque esa salida fue enviada al archivo. Inspeccionar `test001.out` y comprobar que contenga:

```text
Estado: congelacion
```

Si el archivo de salida ya existe, `>` reemplaza su contenido.

#### 2.4. Comparar el resultado

Comparar el resultado esperado con la salida obtenida:

```bash
diff -u tests/test001.expected tests/test001.out
```

La opción `-u` muestra las diferencias en formato unificado. En este formato, las líneas que comienzan con `-` pertenecen al archivo esperado y las que comienzan con `+` pertenecen al resultado obtenido.

Cuando ambos archivos son iguales, `diff` no muestra diferencias. Consultar inmediatamente `$?` y comprobar que sea `0`.

Los códigos de salida de `diff` se interpretan así:

| Código | Significado |
| --- | --- |
| `0` | Los archivos son iguales |
| `1` | Los archivos son diferentes |
| `2` | `diff` no pudo realizar la comparación |

### 3. Trabajar con los canales de salida

#### 3.1. Distinguir `stdout` y `stderr`

El programa utiliza dos canales de salida:

- `stdout` contiene el resultado normal de una ejecución válida
- `stderr` contiene el mensaje asociado a una entrada inválida

El archivo `tests/error.in` contiene una entrada inválida. Ejecutar el programa usando ese archivo como entrada, guardar `stdout` en `tests/error.out` y guardar `stderr` en `tests/error.err`:

```bash
./code/temperatura < tests/error.in > tests/error.out 2> tests/error.err
```

Revisar inmediatamente el código de salida. Luego inspeccionar ambos archivos y comprobar que `error.out` esté vacío y que `error.err` contenga el mensaje de error.

### 4. Repetir y analizar pruebas

#### 4.1. Ejecutar `test002`

Construir los comandos necesarios para repetir con `test002` el mismo flujo realizado en 2.3 y 2.4:

1. Ejecutar el programa con `test002.in`
2. Guardar el resultado en `test002.out`
3. Compararlo con `test002.expected`
4. Revisar el código entregado por `diff`

La prueba debe coincidir con el resultado esperado.

#### 4.2. Ejecutar `test003`

Repetir el flujo manual con los archivos de `test003`. En este caso `diff` debe mostrar una diferencia y entregar código `1`.

Comprobar que `test003.in` y `test003.expected` correspondan a la especificación. El programa contiene un error en una de sus condiciones de borde: localizar la condición responsable dentro de `temperatura.c` y corregirla con Vim.

Volver a compilar el programa con las mismas opciones utilizadas anteriormente y repetir la prueba hasta que `diff` entregue código `0`.

En general, una prueba fallida no demuestra por sí sola que el programa esté equivocado: también se deben revisar la entrada y el resultado esperado. En este caso, esa revisión permite confirmar que el problema se encuentra en el programa.

### 5. Crear un caso de borde

#### 5.1. Construir `test004`

Crear con Vim los archivos `tests/test004.in` y `tests/test004.expected`. El nuevo caso debe comprobar el comportamiento del programa cuando la temperatura es exactamente `20`.

Deducir tanto la entrada como la salida esperada a partir de la especificación. Mantener el mismo formato y la misma convención de nombres de los casos anteriores.

#### 5.2. Ejecutar el nuevo caso manualmente

Construir los comandos necesarios para generar `test004.out`, compararlo con `test004.expected` y revisar el código de `diff`.

Si la prueba no coincide, leer atentamente la comparación, revisar los tres archivos del caso y corregir lo necesario antes de repetirla.

### 6. Automatizar la suite de pruebas

#### 6.1. Inspeccionar el script

Abrir o inspeccionar `scripts/tests-run.sh`. El script automatiza el mismo procedimiento realizado manualmente:

1. Busca archivos cuyo nombre siga el patrón `test<NNN>.in`
2. Obtiene el nombre del archivo `.expected` correspondiente
3. Ejecuta el programa y genera `.out` y `.err`
4. Revisa el código de salida del programa
5. Compara `.expected` y `.out` con `diff`
6. Informa `PASS`, `FAIL` o `ERRO`
7. Presenta un resumen

Los resultados se interpretan así:

- `PASS`: el programa terminó correctamente y la salida coincide
- `FAIL`: el programa terminó correctamente, pero la salida es diferente
- `ERRO`: el programa no pudo ejecutarse correctamente o falta un archivo del test case

#### 6.2. Ejecutar todos los test cases

Revisar los permisos de `tests-run.sh` y agregar permiso de ejecución para el propietario. El script recibe dos argumentos, en este orden:

```text
tests-run.sh <RUTA_AL_EJECUTABLE> <DIRECTORIO_DE_TESTS>
```

Construir el comando necesario para ejecutar desde `workspace` todos los casos de `tests` sobre `code/temperatura`.

Los cuatro casos deben entregar `PASS`. Si aparece un `FAIL`, inspeccionar los archivos `.expected`, `.out` y `.diff` del caso. Si aparece un `ERRO`, revisar el mensaje, el archivo `.err`, las rutas utilizadas y la existencia de todos los componentes del test case.

#### 6.3. Revisar el resultado de la automatización

Consultar el código de salida de `tests-run.sh` inmediatamente después de ejecutar la suite:

- El código es `0` cuando todos los test cases pasan
- El código es `1` cuando existe al menos un `FAIL` o `ERRO`
- El código es `2` cuando los argumentos o las rutas no permiten comenzar las pruebas

Observar los archivos generados dentro de `tests`. Los `.out` registran las salidas obtenidas; los `.diff` y `.err` se conservan únicamente cuando ayudan a analizar una prueba que no pasó.

### 7. Verificación final

#### 7.1. Habilitar el script de verificación

Revisar los permisos de `scripts/check.sh` y agregar permiso de ejecución para el propietario.

#### 7.2. Ejecutar la verificación

Ejecutar `scripts/check.sh` desde `workspace`. El script revisa la compilación, los test cases, la automatización y sus resultados. Cada comprobación señala la subsección correspondiente del laboratorio.
