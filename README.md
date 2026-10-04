# MTC DevOps Hack — Kubernetes Observability & Gateway API Stack

Решение задачи по автоматизированному развертыванию демонстрационного веб-приложения в Kubernetes с настройкой публикации через **Gateway API**, мониторинга на базе **Prometheus/Grafana** и сбора логов через **Filebeat**.

---

## Паспорт инфраструктуры и стек технологий

**ОС**: Ubuntu 24.04 LTS - Операционная система тестирования 
**Kubernetes**: v1.31.0 (Kind) - Локальный Kubernetes-кластер 
**Gateway API**: Envoy Gateway `v1.0.0` - Реализация Gateway Controller 
**Monitoring**: kube-prometheus-stack `v65.x` - Prometheus Operator & Grafana 
**Logging**: Filebeat `8.11.0` - DaemonSet сборщик логов контейнеров 
**Automation**: Bash, Helm v3, Kubectl - Скрипты автоматизации `deploy.sh`

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