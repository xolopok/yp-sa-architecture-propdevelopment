#!/usr/bin/env bash
set -euo pipefail

DOMAIN_NAMESPACES=(sales utilities finance data)

for ns in "${DOMAIN_NAMESPACES[@]}"; do
  kubectl create namespace "${ns}" --dry-run=client -o yaml | kubectl apply -f -
done

kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: security-auditor
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics", "/healthz"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-operator
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["resourcequotas", "limitranges"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies", "ingresses", "ingressclasses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["nodes", "persistentvolumes", "pods", "services", "events"]
  verbs: ["get", "list", "watch"]
EOF

for ns in "${DOMAIN_NAMESPACES[@]}"; do
  kubectl apply -n "${ns}" -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: ${ns}
rules:
- apiGroups: ["", "apps", "batch", "networking.k8s.io"]
  resources: ["pods", "pods/log", "pods/exec", "pods/portforward", "services", "endpoints", "configmaps", "deployments", "replicasets", "statefulsets", "daemonsets", "jobs", "cronjobs", "ingresses", "persistentvolumeclaims"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
EOF
done

echo
kubectl get clusterroles security-auditor cluster-operator
kubectl get roles -A
