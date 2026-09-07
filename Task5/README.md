# Задание 5. Управление трафиком внутри кластера Kubernetes

## Подготовка

Запустить Minikube с CNI, поддерживающим политики:

```console
minikube start --cni=calico
```

## Деплой и тест

Развернуть сервисы:

```console
./scripts/deploy.sh
```

Применить политики:

```console
kubectl apply -f non-admin-api-allow.yaml
```

Запустить тест:

```console
$ ./scripts/test.sh
OK       expected=ALLOWED actual=ALLOWED front-end -> back-end-api
OK       expected=BLOCKED actual=BLOCKED front-end -> admin-front-end
OK       expected=BLOCKED actual=BLOCKED front-end -> admin-back-end-api
OK       expected=ALLOWED actual=ALLOWED back-end-api -> front-end
OK       expected=BLOCKED actual=BLOCKED back-end-api -> admin-front-end
OK       expected=BLOCKED actual=BLOCKED back-end-api -> admin-back-end-api
OK       expected=BLOCKED actual=BLOCKED admin-front-end -> front-end
OK       expected=BLOCKED actual=BLOCKED admin-front-end -> back-end-api
OK       expected=ALLOWED actual=ALLOWED admin-front-end -> admin-back-end-api
OK       expected=BLOCKED actual=BLOCKED admin-back-end-api -> front-end
OK       expected=BLOCKED actual=BLOCKED admin-back-end-api -> back-end-api
OK       expected=ALLOWED actual=ALLOWED admin-back-end-api -> admin-front-end

All checks passed
```
