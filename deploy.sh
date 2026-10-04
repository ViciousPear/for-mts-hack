#!/usr/bin/env bash
set -e

# Делаем все скрипты исполняемыми
chmod +x scripts/*.sh

echo "1. Проверка и установка зависимостей"
./scripts/install_deps.sh

echo "2. Создание или проверка локального кластера Kind"
CLUSTER_NAME="mtc-demo"

if ! kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "Создание кластера ${CLUSTER_NAME}..."
  kind create cluster --name "${CLUSTER_NAME}" --config kind-config.yaml
else
  echo "Кластер '${CLUSTER_NAME}' уже существует."
fi

# Явно переключаем контекст kubectl на созданный кластер
echo "Переключение контекста kubectl на kind-${CLUSTER_NAME}..."
kubectl config use-context "kind-${CLUSTER_NAME}"

echo "3. Ожидание готовности Kubernetes API"
until kubectl cluster-info &>/dev/null; do
  echo "Ожидание запуска API-сервера..."
  sleep 3
done

echo "4. Запуск развертывания приложений и мониторинга"
./scripts/deploy.sh

echo "Развертывание успешно завершено!"