#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

GATEKEEPER_VERSION="${GATEKEEPER_VERSION:-3.23.1}"

DIRS=(allowed_repos capabilities priv-esc privileged required_labels resource_limits seccomp)
CRDS=(
  k8sallowedrepos.constraints.gatekeeper.sh
  k8spspcapabilities.constraints.gatekeeper.sh
  k8spspallowprivilegeescalationcontainer.constraints.gatekeeper.sh
  k8spspprivilegedcontainer.constraints.gatekeeper.sh
  k8srequiredlabels.constraints.gatekeeper.sh
  k8scontainerlimits.constraints.gatekeeper.sh
  k8spspseccomp.constraints.gatekeeper.sh
)

helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update

helm upgrade --install gatekeeper gatekeeper/gatekeeper \
  --namespace gatekeeper-system \
  --create-namespace \
  --version "${GATEKEEPER_VERSION}"

kubectl wait --for=condition=Available deployment/gatekeeper-controller-manager \
  -n gatekeeper-system --timeout=180s

for dir in "${DIRS[@]}"; do
  kubectl apply -f "${dir}/template.yaml"
done

for crd in "${CRDS[@]}"; do
  kubectl wait --for=condition=Established --timeout=120s "crd/${crd}"
done

for dir in "${DIRS[@]}"; do
  kubectl apply -f "${dir}/constraint.yaml"
done
