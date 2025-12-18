# Django приложение для Kubernetes

## Структура проекта
- `apps/django-app/` - манифесты приложения
- `overlays/minikube/` - конфигурация для Minikube
- `overlays/yc-dev/` - конфигурация для Яндекс.Облака
- `overlays/yc-dev-2/` - второе окружение YC

## Быстрый старт
1. Собрать образ: \`docker build -t my-django-unit .\`
2. Развернуть в Minikube: \`kubectl apply -k overlays/minikube/\`

## Как подготовить dev окружение

### 1. Создание секрета с SSL-сертификатом PostgreSQL
```bash
kubectl get secret postgres -n edu-evgenij-sozykin -o jsonpath='{.data.root\.crt}' | \\
  kubectl create secret generic postgres-ssl-cert \\
    -n edu-evgenij-sozykin \\
    --from-file=root.crt=/dev/stdin \\
    --dry-run=client -o yaml > postgres-ssl-secret.yaml
kubectl apply -f postgres-ssl-secret.yaml