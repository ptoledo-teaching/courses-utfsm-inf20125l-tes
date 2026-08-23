#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
CODE_DIR="${WORKSPACE}/code"
TESTS_DIR="${WORKSPACE}/tests"
PASSES=0
FAILURES=0

pass() {
    printf 'PASS: %s\n' "$1"
    PASSES=$((PASSES + 1))
}

fail() {
    printf 'FAIL: %s\n' "$1"
    FAILURES=$((FAILURES + 1))
}

check() {
    local description="$1"
    shift

    if "$@"; then
        pass "${description}"
    else
        fail "${description}"
    fi
}

content_equals() {
    local path="$1"
    local expected="$2"

    [[ -f "${path}" ]] || return 1
    [[ "$(cat -- "${path}")" == "${expected}" ]]
}

compiles_without_warnings() {
    gcc -Wall -Wextra -Werror -std=c11 -fsyntax-only "${CODE_DIR}/temperatura.c" >/dev/null 2>&1
}

is_binary_executable() {
    local path="$1"
    local description=""

    [[ -f "${path}" && -x "${path}" ]] || return 1
    description="$(file -b -- "${path}")"
    [[ "${description}" == ELF*executable* ]]
}

suite_passes() {
    "${SCRIPT_DIR}/tests-run.sh" "${CODE_DIR}/temperatura" "${TESTS_DIR}" >/dev/null 2>&1
}

files_match() {
    local first="$1"
    local second="$2"

    [[ -f "${first}" && -f "${second}" ]] || return 1
    cmp -s -- "${first}" "${second}"
}

test003_passes() {
    local output=""

    output="$("${CODE_DIR}/temperatura" < "${TESTS_DIR}/test003.in" 2>/dev/null)" || return 1
    [[ "${output}" == 'Estado: calor' ]]
}

printf '%s\n' '========================================='
printf '%s\n' '==   Verificación de laboratorio TES   =='
printf '%s\n' '========================================='
printf '\n== Actividades ==========================\n\n'

check "[1.2] temperatura.c compila sin warnings" compiles_without_warnings
check "[1.2] temperatura existe como binario ejecutable" is_binary_executable "${CODE_DIR}/temperatura"

check "[4.2] temperatura clasifica correctamente el valor 30" test003_passes

check "[5.1] test004.in existe" test -f "${TESTS_DIR}/test004.in"
check "[5.1] test004.expected existe" test -f "${TESTS_DIR}/test004.expected"
check \
    "[5.1] test004.in representa el caso de borde solicitado" \
    content_equals "${TESTS_DIR}/test004.in" '20'
check \
    "[5.1] test004.expected contiene el resultado correcto" \
    content_equals "${TESTS_DIR}/test004.expected" 'Estado: templado'

check "[6.2] tests-run.sh tiene permiso de ejecución" test -x "${SCRIPT_DIR}/tests-run.sh"
check "[6.2] La suite automatizada finaliza correctamente" suite_passes

for test_name in test001 test002 test003 test004; do
    check \
        "[6.3] ${test_name}.out coincide con ${test_name}.expected" \
        files_match \
        "${TESTS_DIR}/${test_name}.expected" \
        "${TESTS_DIR}/${test_name}.out"
done

check "[7.1] check.sh tiene permiso de ejecución" test -x "${SCRIPT_DIR}/check.sh"

printf '\n== Resumen ===============================\n\n'
TOTAL=$((PASSES + FAILURES))
COUNT_WIDTH=${#TOTAL}
printf '%-26s %*d\n' 'Comprobaciones exitosas:' "${COUNT_WIDTH}" "${PASSES}"
printf '%-26s %*d\n\n' 'Comprobaciones pendientes:' "${COUNT_WIDTH}" "${FAILURES}"

if (( FAILURES == 0 )); then
    exit 0
fi

exit 1
