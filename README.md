# intrusion-prevention

Gatekeeper (OPA) admission policies for Kube-Shield. The constraints are scoped
to the `crapi` namespace and block workloads that violate the pod hardening
baseline used by the `manifests` repository.

## Layout

Each constraint lives in its own directory:

```
<constraint>/
  template.yaml        ConstraintTemplate (policy logic)
  constraint.yaml      Constraint (scope and parameters)
  pod_test_allow.yaml  Object accepted by the policy
  pod_test_deny.yaml   Object rejected by the policy
suite.yaml             gator verify test suite
scripts/install.sh     Gatekeeper installation and policy apply
```

## Constraints

| Directory | Kind | Enforces |
|---|---|---|
| `allowed_repos` | K8sAllowedRepos | Images come from approved registries used by crAPI |
| `capabilities` | K8sPSPCapabilities | No added capabilities and `ALL` dropped |
| `priv-esc` | K8sPSPAllowPrivilegeEscalationContainer | `allowPrivilegeEscalation: false` |
| `privileged` | K8sPSPPrivilegedContainer | No privileged containers |
| `required_labels` | K8sRequiredLabels | Namespaces carry a valid `owner` label |
| `resource_limits` | K8sContainerLimits | CPU and memory limits within allowed maximums |
| `seccomp` | K8sPSPSeccomp | `RuntimeDefault` seccomp profile |

All seven constraints use `enforcementAction: deny`, so violations are rejected
at admission time.

## Prerequisites

- Kubernetes cluster with admission webhooks enabled
- Helm 3.12+
- `kubectl`
- `gator` (only for local verification)

## Install

```bash
./scripts/install.sh
```

Environment override:

| Variable | Default | Purpose |
|---|---|---|
| `GATEKEEPER_VERSION` | `3.23.1` | Pin the Gatekeeper Helm chart version |

The script installs Gatekeeper, applies all ConstraintTemplates, waits for the
generated CRDs, then applies the constraints in dependency order.

## Verify

Run the policy tests locally or in CI:

```bash
gator verify suite.yaml
```

The GitHub Actions workflow `.github/workflows/validate.yaml` runs the same suite
on every push and pull request.

Admission checks on the cluster:

```bash
kubectl get constraints
kubectl apply -f capabilities/pod_test_deny.yaml
```

## Customizing

- Update `constraint.yaml` to change scope or parameters; `template.yaml` holds
  the reusable policy logic.
- Copy the test object under a new name when adding cases, then extend
  `suite.yaml` with the object and an assertion.
- The `crapi` namespace must exist before policies are exercised; it is created
  by the `manifests` deployment.
