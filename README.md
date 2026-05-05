# Helm chart — controlplane

In the **`fluid`** monorepo this chart lives under `code/charts/fluid-controlplane/`; standalone Git (**`fluid-pub/chart-controlplane`**) uses the same layout at the repository root.

**Release (standalone repo)** — **`helm lint`** runs on PRs and `main` / `develop`; pushing a semver tag **without `v`** runs **`helm push … oci://ghcr.io/<GitHub-owner>/fluid-controlplane`** when the tag equals **`version`** in **`Chart.yaml`**.

**Install / pull from GHCR** — Helm OCI on GitHub stores the chart under a path that repeats the chart **`name:`** (see the package page `fluid-controlplane/fluid-controlplane`). Use **`--version`** with the full OCI prefix, for example:

```text
helm pull oci://ghcr.io/fluid-pub/fluid-controlplane/fluid-controlplane --version 0.1.0
```

or the equivalent tag form **`oci://ghcr.io/fluid-pub/fluid-controlplane/fluid-controlplane:0.1.0`**. The shorter reference **`oci://ghcr.io/fluid-pub/fluid-controlplane`** (without the second **`fluid-controlplane`**) does **not** resolve with **`helm pull` / `helm install`** against this registry layout.

Application-only chart: **no** bundled PostgreSQL and **no Secret management** in the chart.
Provide credentials via pre-existing Kubernetes Secret(s), referenced in `envFromSecrets`.

By default, traffic exposure uses **Gateway API** (`gatewayApi.enabled: true`, `HTTPRoute`).

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
- `PHX_HOST`
- `PORT` (typically `4000`)

Optional keys depend on enabled features (LLM, RAG, enrollment, etc.) — see `code/controlplane/config/runtime.exs`.

## Probes

Defaults:

- **Liveness** — `GET /health/live` (no database check).
- **Readiness** — `GET /health/ready` (checks database connectivity).

Override paths under `livenessProbe` / `readinessProbe` in values if needed.