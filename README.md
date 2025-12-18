
# Запуск манифестов в Minikube

## Порядок запуска манифестов

### 1. Запуск Minikube и настройка окружения

```bash
# Запускаем Minikube
minikube start

# Настраиваем Docker для работы с Minikube
eval $(minikube docker-env)
```

### 2. Сборка Docker образа

```bash
# Собираем образ приложения
docker build --no-cache -t my-django-unit:latest .
```

### 3. Запуск манифестов в ПРАВИЛЬНОМ ПОРЯДКЕ

#### Шаг 1: Установка PostgreSQL через Helm

```bash

helm install postgresql bitnami/postgresql \
  --set auth.postgresPassword=postgres \
  --set auth.database=starburger \
  --set auth.username=django \
  --set auth.password=django123 \
  --set fullnameOverride=postgresql \
  --set primary.persistence.enabled=false \
  --set auth.existingSecret=""

# Ждем пока PostgreSQL запустится
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=postgresql --timeout=300s
```

#### Шаг 2: Применение Secrets
```bash
kubectl apply -f django-secret.yaml
```

#### Шаг 3: Запуск миграций базы данных
```bash
kubectl apply -f migrate-job.yaml


# Проверяем что миграции завершились успешно
kubectl wait --for=condition=complete job/django-migrate --timeout=300s
```
#### Шаг 4: Создание суперпользователя

```bash
kubectl apply -f createsuperuser-job.yaml

# Проверяем создание суперпользователя
kubectl wait --for=condition=complete job/django-createsuperuser --timeout=300s
```

#### Шаг 5: Запуск основного приложения

```bash

kubectl apply -f django-deployment.yaml
kubectl apply -f django-service.yaml
```

#### Шаг 6: Настройка Ingress
```bash
kubectl apply -f django-ingress.yaml
```

#### Шаг 7: Настройка периодических задач

```bash
kubectl apply -f django-cronjob.yaml
```

### 4. Настройка домена в системе

```bash
# Добавляем домен в hosts файл
echo "$(minikube ip) star-burger.test" | sudo tee -a /etc/hosts
```

## Проверка работы

### Проверка статуса всех компонентов
```bash
kubectl get all
```

### Проверка конкретных компонентов
```bash
# Проверяем поды приложения
kubectl get pods -l app=django-app

# Проверяем сервисы
kubectl get services

# Проверяем ingress
kubectl get ingress

# Проверяем jobs
kubectl get jobs

# Проверяем cronjobs
kubectl get cronjobs
```

### Проверка логов
```bash
# Логи основного приложения
kubectl logs -l app=django-app

# Логи миграций
kubectl logs job/django-migrate

# Логи создания суперпользователя
kubectl logs job/django-createsuperuser
```

### Если нужно пересобрать и перезапустить приложение
```bash
# Пересобираем образ
docker build --no-cache -t my-django-unit:latest .

# Перезапускаем deployment (создаст новые поды с новым образом)
kubectl rollout restart deployment/django-deployment
```

### Если нужно обновить конфигурацию
```bash
# Применяем измененные манифесты
kubectl apply -f django-deployment.yaml
```

### Если нужно очистить и перезапустить всё
```bash
# Удаляем все ресурсы (кроме PostgreSQL)
kubectl delete -f .

# Перезапускаем в правильном порядке
kubectl apply -f django-secret.yaml
kubectl apply -f migrate-job.yaml
kubectl apply -f createsuperuser-job.yaml
kubectl apply -f django-deployment.yaml
kubectl apply -f django-service.yaml
kubectl apply -f django-ingress.yaml
kubectl apply -f django-cronjob.yaml
```

## Важные моменты

1.  **Порядок важен** - сначала база данных, потом миграции, потом приложение
    
2.  **Ждите готовности** - используйте `kubectl wait` чтобы дождаться готовности компонентов
    
3.  **Проверяйте логи** - если что-то не работает, смотрите логи соответствующих подов
    
4.  **Ingress может потребовать доп. настройки** - в Minikube может потребоваться включить ingress addon:
 ```bash
   minikube addons enable ingress
 ```
После выполнения всех шагов приложение будет доступно по адресу: `http://star-burger.test/admin/`

## Развёртывание в Yandex Cloud

**Домен:** `edu-evgenij-sozykin.yc-sirius-dev.pelid.team`  
**HTTPS:** Настроен автоматически через Ingress.

### Текущая конфигурация:
- **Ingress:** `main` (маршрутизирует трафик с домена на поды)
- **Pod:** `test-nginx` (тестовый веб-сервер)

### Как обновить:
1. Собрать образ: `docker build -t my-django-unit .`
2. Обновить Pod: `kubectl apply -f apps/django-app/test-nginx-pod.yaml`