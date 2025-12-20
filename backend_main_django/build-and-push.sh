#!/bin/bash

DOCKER_REPO="evgeny1337depo/k8s-django-site"
GIT_COMMIT_HASH=$(git rev-parse --short HEAD)


echo "🔨 Сборка образа с тегом: $DOCKER_REPO:$GIT_COMMIT_HASH"
docker build -t $DOCKER_REPO:$GIT_COMMIT_HASH .


echo "Создание тега latest"
docker tag $DOCKER_REPO:$GIT_COMMIT_HASH $DOCKER_REPO:latest


echo "Публикация образа $DOCKER_REPO:$GIT_COMMIT_HASH"
docker push $DOCKER_REPO:$GIT_COMMIT_HASH

echo "Публикация образа $DOCKER_REPO:latest"
docker push $DOCKER_REPO:latest

echo "Готово! Образы:"
echo "   - $DOCKER_REPO:$GIT_COMMIT_HASH"
echo "   - $DOCKER_REPO:latest"