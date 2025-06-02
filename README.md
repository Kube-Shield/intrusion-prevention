# Gatekeeper Constraints Demo

This repository showcases three Gatekeeper constraints, each in its own folder. Every folder contains:

- A `template.yaml`: The ConstraintTemplate definition.
- A `constraint.yaml`: The Constraint that enforces the policy.
- An `allowed-pod.yaml`: A pod manifest that **complies** with the policy.
- A `denied-pod.yaml`: A pod manifest that **violates** the policy.

## Constraints Overview
### We will showcase 3 constraints.
- Ressource limits: the contstraint file will be substituted (the cpu and memory) , using envsubst
- Capabilities: The allowed and required drop capabilities will be lists , thus we cant use envsubst we will use yq
- Privileged: we dont have any fields to fill.
