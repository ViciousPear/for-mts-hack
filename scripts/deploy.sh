#!/usr/bin/env bash
set -e


CLUSTER_NAME="mtc-demo"
kubectl config use-context "kind-${CLUSTER_NAME}" &>/dev/null || true

echo "3. Установка Gateway API Controller (Envoy Gateway)"
helm repo add eg https://gateway.envoyproxy.io
helm repo update eg

helm upgrade --install eg eg/gateway-helm \
  --version v1.0.0 \
  --namespace envoy-gateway-system \
  --create-namespace \
  --timeout 10m0s \
  --wait

echo "Ожидаем готовности CRD Gateway API..."
kubectl wait --for=condition=established --timeout=60s crd/gateways.gateway.networking.k8s.io 2>/dev/null || sleep 10

echo "4. Развертывание веб-приложения"
kubectl apply -f manifests/01-app/

echo "5. Применение ресурсов Gateway API"
kubectl apply -f manifests/02-gateway/

echo "6. Развертывание Prometheus"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --timeout 10m0s \
  -f manifests/03-monitoring/values.yaml

echo "Ожидаем готовности CRD Prometheus..."
kubectl wait --for=condition=established --timeout=60s crd/servicemonitors.monitoring.coreos.com 2>/dev/null || sleep 5

kubectl apply -f manifests/03-monitoring/servicemonitor.yaml

echo "7. Развертывание Filebeat"
kubectl apply -f manifests/04-logging/

echo "Ожидание готовности подов Filebeat"
kubectl rollout status daemonset/filebeat -n logging --timeout=120s || true

echo " Развертывание всех сервисов успешно завершено!"