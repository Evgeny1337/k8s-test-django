# Django приложение для Kubernetes

## Структура проекта
- `apps/django-app/` - манифесты приложения
- `overlays/minikube/` - конфигурация для Minikube
- `overlays/yc-dev/` - конфигурация для Яндекс.Облака
- `overlays/yc-dev-2/` - второе окружение YC

## Быстрый старт
1. Собрать образ: \`docker build -t my-django-unit .\`
2. Развернуть в Minikube: \`kubectl apply -k overlays/minikube/\`
