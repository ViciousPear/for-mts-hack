#!/usr/bin/env bash
set -e

echo "Проверка необходимых CLI утилит"

REQUIRED_TOOLS=("docker" "kind" "kubectl" "helm")
MISSING_TOOLS=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        MISSING_TOOLS+=("$tool")
    else
        echo " [OK] $tool установлен"
    fi
done

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo " Ошибка: Не найдены следующие утилиты: ${MISSING_TOOLS[*]}"
    echo " Пожалуйста, установите их перед запуском развертывания."
    exit 1
fi

# Проверка, запущен ли Docker Daemon
if ! docker info &> /dev/null; then
    echo " Ошибка: Docker запущен не или недоступен без sudo!"
    exit 1
fi

echo "Все зависимости успешно проверены."