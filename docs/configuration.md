# Configuration reference

## Workflow example with explicit names

```yaml
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: AbdRaqeeb/coolify-deploy@v1
        with:
          app-id: ${{ vars.COOLIFY_APP_ID }}
          image-tag: ${{ github.sha }}
          base-url: ${{ vars.DEPLOY_API_BASE_URL }}
          deploy-api-token: ${{ secrets.DEPLOY_API_TOKEN }}
```

## Inputs (detailed)

### `app-id`

UUID or string identifier your Coolify (or compatible) instance uses for the application resource.

### `image-tag`

Value written to `docker_registry_image_tag` on the application (for example Git commit SHA, semver tag, or digest reference your registry supports).

### `base-url`

Scheme + host (+ optional port), **no trailing slash**. Example: `https://app.coolify.example.com`. All requests are built as `{base-url}/api/v1/...`.

### `deploy-api-token`

Sent as `Authorization: Bearer <token>`. Store only in **Secrets**, never in variables or logs.

The composite action always runs each step with `bash` and the script path, so file modes do not matter on the runner.

## Optional: running scripts locally

The same scripts accept `--token` or the `TOKEN` environment variable. Poll tuning when not using the composite action:

```bash
export TOKEN="your-bearer-token"
export POLL_INTERVAL_SECONDS=5
export MAX_WAIT_SECONDS=1800
./scripts/04-wait-deployment.sh --baseUrl 'https://example.com' --deploymentUuid '...'
```

See `--help` on each script under `scripts/`.
