# Задание 4. Защита доступа к кластеру Kubernetes

Ролевая модель описана в файле `roles.md`.

## Настройка

Для запуска нужны запущенный Minikube, `kubectl` и `openssl` (для генерации сертифкатов).

Выполнить скрипты:

1. `./create-users.sh` -- создаёт клиентов кластера (сертификаты подписываются CA Minikube) и контексты kubeconfig: `platform-admin`, `security-auditor`, `devops-engineer`, `developer-sales`, `developer-utilities`, `developer-finance`, `developer-data`, `viewer`.
2. `./create-roles.sh` -- создаёт namespace доменов (`sales`, `utilities`, `finance`, `data`), ClusterRole `security-auditor`, `cluster-operator` и Role `developer` в каждом namespace домена.
3. `./create-bindings.sh` -- связывает пользователей с ролями (ClusterRoleBinding / RoleBinding).

Пользователь `viewer` привязан к встроенной роли `view`, которая по умолчанию не даёт
доступ к секретам. Пользователь `platform-admin` привязан к встроенной роли
`cluster-admin`. Наименования namespace соответствуют доменам из описания компании.

## Проверка

```console
$ kubectl auth can-i --as=security-auditor get secrets -A
yes
$ kubectl auth can-i --as=viewer get secrets
no
$ kubectl auth can-i --as=devops-engineer create namespaces
yes
$ kubectl auth can-i --as=devops-engineer get secrets
no
$ kubectl auth can-i --as=developer-sales create deployments -n sales
yes
$ kubectl auth can-i --as=developer-sales create deployments -n utilities
no
$ kubectl auth can-i --as=viewer delete pods -n sales
no
$ kubectl auth can-i --as=platform-admin delete nodes
yes
```
