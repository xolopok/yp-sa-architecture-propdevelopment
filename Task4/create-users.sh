#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="${SCRIPT_DIR}/certs"
mkdir -p "${CERT_DIR}"

MINIKUBE_HOME="${MINIKUBE_HOME:-${HOME}/.minikube}"
CA_CRT="${MINIKUBE_HOME}/ca.crt"
CA_KEY="${MINIKUBE_HOME}/ca.key"
CLUSTER="minikube"

USERS=(
  "platform-admin:PlatformAdministrators"
  "security-auditor:InfoSec"
  "devops-engineer:DevOps"
  "developer-sales:Sales"
  "developer-utilities:Utilities"
  "developer-finance:Finance"
  "developer-data:Data"
  "viewer:Operations"
)

if [[ ! -f "${CA_CRT}" || ! -f "${CA_KEY}" ]]; then
  echo "Minikube CA not found at ${CA_CRT} and ${CA_KEY}" >&2
  exit 1
fi

for entry in "${USERS[@]}"; do
  user="${entry%%:*}"
  group="${entry##*:}"

  openssl genrsa -out "${CERT_DIR}/${user}.key" 2048
  openssl req -new -key "${CERT_DIR}/${user}.key" \
    -subj "/CN=${user}/O=${group}" \
    -out "${CERT_DIR}/${user}.csr"
  openssl x509 -req -in "${CERT_DIR}/${user}.csr" \
    -CA "${CA_CRT}" -CAkey "${CA_KEY}" -CAcreateserial \
    -out "${CERT_DIR}/${user}.crt" -days 365

  kubectl config set-credentials "${user}" \
    --client-certificate="${CERT_DIR}/${user}.crt" \
    --client-key="${CERT_DIR}/${user}.key" \
    --embed-certs=true
  kubectl config set-context "${user}@${CLUSTER}" \
    --cluster="${CLUSTER}" \
    --user="${user}"

  echo "User '${user}' (group ${group}) created"
done

echo
kubectl config get-contexts
