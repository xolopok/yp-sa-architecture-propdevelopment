# PropDevelopment: ролевая модель

Просмотр секретов разрешён только администраторам платформы и специалисту по ИБ.

| Роль | Права роли | Группы пользователей |
| --- | --- | --- |
| `cluster-admin` (встроенная ClusterRole) | Полный доступ ко всем ресурсам кластера: все действия над любыми ресурсами, включая секреты, RBAC и узлы. Используется для администрирования платформы и исключительных ситуаций. | Администраторы платформы / инфраструктуры (user `platform-admin`) |
| `security-auditor` (ClusterRole) | Привилегированный доступ только на чтение: `get/list/watch` по всем ресурсам всех API-групп, включая секреты, логи подов и события; чтение nonResourceURLs (`/metrics`, `/healthz`). Изменять ресурсы не может. Назначение: аудит безопасности, расследование инцидентов. | Специалист по ИБ (user `security-auditor`) |
| `cluster-operator` (ClusterRole) | Настройка кластера: создание и изменение namespace, ResourceQuota/LimitRange, NetworkPolicy, Ingress/IngressClass; чтение узлов, PV, StorageClass, подов, сервисов и событий. Нет доступа к секретам, RBAC и узлам на запись. | DevOps-инженеры функциональных команд (user `devops-engineer`) |
| `developer` (Role, создаётся в namespace каждого домена: `sales`, `utilities`, `finance`, `data`) | Полное управление ресурсами приложений внутри своего namespace: deployments, replicasets, statefulsets, daemonsets, pods (+ `log`, `exec`, `portforward`), services, endpoints, configmaps, jobs, cronjobs, ingresses, PVC. Нет доступа к секретам, RBAC, узлам и ресурсам чужих доменов. | Разработчики функциональных команд по доменам (users `developer-sales`, `developer-utilities`, `developer-finance`, `developer-data`) |
| `view` (встроенная ClusterRole) | Просмотр (`get/list/watch`) ресурсов в namespace кластера, кроме секретов. Изменять ресурсы не может. | Операционные команды, бизнес-аналитики (user `viewer`) |
