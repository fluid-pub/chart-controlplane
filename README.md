# Helm chart — controlplane

In the **`fluid`** monorepo this chart lives under `code/charts/fluid-controlplane/`; standalone Git (**`fluid-pub/chart-controlplane`**) uses the same layout at the repository root.

**Release (standalone repo)** — **`helm lint`** runs on PRs and `main` / `develop`; pushing a semver tag **without `v`** runs **`helm push … oci://ghcr.io/<GitHub-owner>/fluid-controlplane`** when the tag equals **`version`** in **`Chart.yaml`**.

**Install / pull from GHCR** — Helm OCI on GitHub stores the chart under a path that repeats the chart **`name:`** (see the package page `fluid-controlplane/fluid-controlplane`). Use **`--version`** with the full OCI prefix, for example:

```text
helm pull oci://ghcr.io/fluid-pub/fluid-controlplane/fluid-controlplane --version 0.2.0
```

or the equivalent tag form **`oci://ghcr.io/fluid-pub/fluid-controlplane/fluid-controlplane:0.2.0`**. The shorter reference **`oci://ghcr.io/fluid-pub/fluid-controlplane`** (without the second **`fluid-controlplane`**) does **not** resolve with **`helm pull` / `helm install`** against this registry layout.

Application-only chart: **no** bundled PostgreSQL and **no Secret management** in the chart.
Provide credentials via pre-existing Kubernetes Secret(s), referenced in `envFromSecrets`.

By default, traffic exposure uses **Gateway API** (`gatewayApi.enabled: true`, `HTTPRoute`).

## Multi-replica execution agents (WebSocket affinity)

When `replicaCount` is greater than 1 and `gatewayApi.enabled` is true, the chart creates a dedicated **HTTPRoute** for `/v1/agents/websocket` and a **BackendTrafficPolicy** (Envoy Gateway) with **consistent hash** on the **`authorization`** request header.

Execution agents must send `Authorization: Bearer <connection_token>` on every WebSocket upgrade (in addition to `organization_uuid` and `token` in the query string for Phoenix auth). The same Bearer routes to the same control plane pod while that pod is healthy; after a pod failure, the agent reconnects and may land on another replica.

Opt out: `gatewayApi.agentAffinity.enabled: false`. Force on with a single replica: `gatewayApi.agentAffinity.enabled: true`.

Verify after deploy:

```bash
kubectl get httproute,backendtrafficpolicy -n <namespace>
```

Do not rely on Service `sessionAffinity: ClientIP` alone for agent tunnels (unreliable behind proxies).

## Chart tests

Install [helm-unittest](https://github.com/helm-unittest/helm-unittest) and run from this directory:

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest --version v0.6.3 --verify=false
helm unittest .
```

See [`tests/README.md`](tests/README.md) for suite coverage. CI runs `helm lint` and `helm unittest .` on pull requests.

## Hooks

| Helm hook     | Container command                                  |
|---------------|----------------------------------------------------|
| `pre-install` | `/app/bin/setup` (`ecto.create` + migrate + seeds) |
| `pre-upgrade` | `/app/bin/migrate` (migrations only)               |

Use the **same** image tag as the Deployment (`values.yaml` → `image.repository` / `image.tag`).

## Required Secret keys (production)

Create one or more Secrets in the release namespace, then list them in `envFromSecrets`.
Minimum keys consumed by `runtime.exs`:

- `DATABASE_URL`
- `SECRET_KEY_BASE`
- `CONTROLPLANE_VAULT_SECRET`
- `ENROLLMENT_TOKEN_FINGERPRINT_SECRET`
- `PHX_HOST`
- `PORT` (typically `4000`)

Optional keys depend on enabled features (LLM, RAG, enrollment, etc.) — see `code/controlplane/config/runtime.exs`.

## Probes

Defaults:

- **Liveness** — `GET /health/live` (no database check).
- **Readiness** — `GET /health/ready` (checks database connectivity).

Override paths under `livenessProbe` / `readinessProbe` in values if needed.