# Helm chart unit tests (`fluid-controlplane`)

Unit tests for this chart live under [`tests/`](tests/) and run with [helm-unittest](https://github.com/helm-unittest/helm-unittest).

## Install plugin

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest --version v0.6.3 --verify=false
```

## Run tests

From the chart root:

```bash
helm unittest .
```

Run a single suite:

```bash
helm unittest tests/httproute_agents_test.yaml
```

## Coverage

| Suite | Templates |
|-------|-----------|
| `deployment_test.yaml` | `deployment.yaml` |
| `service_test.yaml` | `service.yaml` |
| `httproute_test.yaml` | `httproute.yaml` |
| `httproute_agents_test.yaml` | `httproute-agents.yaml` |
| `backendtrafficpolicy_agents_test.yaml` | `backendtrafficpolicy-agents.yaml` |
| `backendtrafficpolicy_liveview_test.yaml` | `backendtrafficpolicy-liveview.yaml` |
| `job_setup_test.yaml` | `job-setup.yaml` |
| `job_migrate_test.yaml` | `job-migrate.yaml` |

Shared fixture values: [`tests/data/test_values.yaml`](data/test_values.yaml).

CI runs `helm lint` and `helm unittest .` on every pull request (see [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)).

When you add or change a template or a values branch, add or update tests in the same change.
