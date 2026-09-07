#!/usr/bin/env bash
set -euo pipefail

kubectl create namespace app --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n app -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: front-end-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: front-end
  template:
    metadata:
      labels:
        app: front-end
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: back-end-api-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: back-end-api
  template:
    metadata:
      labels:
        app: back-end-api
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admin-front-end-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: admin-front-end
  template:
    metadata:
      labels:
        app: admin-front-end
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admin-back-end-api-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: admin-back-end-api
  template:
    metadata:
      labels:
        app: admin-back-end-api
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: front-end-app
spec:
  selector:
    app: front-end
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: back-end-api-app
spec:
  selector:
    app: back-end-api
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: admin-front-end-app
spec:
  selector:
    app: admin-front-end
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: admin-back-end-api-app
spec:
  selector:
    app: admin-back-end-api
  ports:
  - port: 80
    targetPort: 80
EOF

kubectl wait --for=condition=available deployment --all -n app --timeout=300s

echo
kubectl get pods,svc -n app
