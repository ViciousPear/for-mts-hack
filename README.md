# MTC DevOps Hack — Kubernetes Observability & Gateway API Stack

Решение задачи по автоматизированному развертыванию демонстрационного веб-приложения в Kubernetes с настройкой публикации через **Gateway API**, мониторинга на базе **Prometheus/Grafana** и сбора логов через **Filebeat**.

---

## Паспорт инфраструктуры и стек технологий

- **ОС**: Ubuntu 24.04 LTS - Операционная система тестирования 
- **Kubernetes**: v1.31.0 (Kind) - Локальный Kubernetes-кластер 
- **Gateway API**: Envoy Gateway `v1.0.0` - Реализация Gateway Controller 
- **Monitoring**: kube-prometheus-stack `v65.x` - Prometheus Operator & Grafana 
- **Logging**: Filebeat `8.11.0` - DaemonSet сборщик логов контейнеров 
- **Automation**: Bash, Helm v3, Kubectl - Скрипты автоматизации `deploy.sh`

---

## Требования к среде (Prerequisites)

Для успешного запуска на Ubuntu 24.04 необходимы утилиты:
- **Docker** (`>= 24.0`)
- **Kind** (`>= 0.20.0`)
- **Kubectl** (`>= 1.28`)
- **Helm** (`>= 3.10`)

*Скрипт `scripts/install_deps.sh` автоматически проверит наличие всех утилит перед стартом.*

---

## Быстрый запуск (One-Command Deployment)

Развертывание всей инфраструктуры с нуля выполняется одной командой:
```bash
chmod +x deploy.sh
./deploy.sh

### Настраиваемые метрики (Prometheus Metrics)

Сбор метрик организован с помощью **Prometheus Operator** и ресурса `ServiceMonitor` (`web-app-monitor`). Стек собирает следующие категории метрик:

1. **Инфраструктурные метрики контейнера приложения (kubelet / cAdvisor):**
   * `container_cpu_usage_seconds_total` — общее время использования процессорного времени контейнером `web-app`.
   * `container_memory_working_set_bytes` — объем используемой оперативной памяти (RAM).
   * `container_network_transmit_bytes_total` / `container_network_receive_bytes_total` — объем сетевого трафика Pod'а.

2. **Метрики состояния Kubernetes Pod / Deployment:**
   * `kube_pod_status_phase` — текущий статус Pod'а (Running, Pending, Failed).
   * `kube_deployment_status_replicas_available` — количество доступных реплик веб-приложения.

3. **Метрики сети и Gateway API (Envoy Gateway):**
   * `envoy_http_downstream_rq_total` — общее количество поступающих HTTP-запросов на Gateway.
   * `envoy_http_downstream_rq_xx` — распределение ответов по HTTP-кодам (2xx, 4xx, 5xx).

### Как проверить получение метрик:
   Выполните проброс порта к Prometheus:
   ```bash
   kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring

### Настраиваемое логирование (Filebeat Logging)

Сбор логов веб-приложения `web-app` (Nginx) осуществляется агентом **Filebeat** (`DaemonSet`), который монтирует системную директорию ноды `/var/log/pods` и считывает логи из `stdout`/`stderr` контейнеров.

1. **Типы собираемых логов:**
   * **Access-логи HTTP-запросов (Nginx stdout):** IP-адрес клиента, штамп времени, HTTP-метод (`GET`, `POST`), URI запроса, статус ответа (`200 OK`, `404 Not Found`), размер ответа, User-Agent.
   * **Error-логи приложения (Nginx stderr):** Сообщения об ошибках конфигурации, сбоях соединений или недоступности бэкенда.

2. **Структура и метаданные лога (Kubernetes Enrichment):**
   Filebeat автоматически структурирует логи в JSON и обогащает их контекстными метаданными Kubernetes:
   * `kubernetes.pod.name` — имя Pod'а приложения (например, `web-app-585b6b8989-x8z2l`).
   * `kubernetes.namespace` — пространство имен (`default`).
   * `kubernetes.container.name` — имя контейнера (`web-app`).
   * `message` — сырая строка access/error лога Nginx.

