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
      - uses: YOUR_ORG/coolify-deploy@v1
        with:
          app-id: ${{ vars.COOLIFY_APP_ID }}
          image-tag: ${{ github.sha }}
          base-url: ${{ vars.DEPLOY_API_BASE_URL }}
          deploy-api-token: ${{ secrets.DEPLOY_API_TOKEN }}
          deploy-use-chmod: "true"
          deploy-use-bash: "false"
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

### `deploy-use-chmod` (default `true`)

When `true`, the action runs `chmod +x` on every `*.sh` file in `scripts/` before invoking them. Recommended on runners where execute bits might be missing after checkout.

### `deploy-use-bash` (default `false`)

- `false`: run `"${{ github.action_path }}/scripts/01-get-app.sh" ...` (requires executable bit if `deploy-use-chmod` is `true`).
- `true`: run `bash /path/to/script.sh ...` (does not rely on execute bit).

## Optional: running scripts locally

The same scripts accept `--token` or the `TOKEN` environment variable. Poll tuning when not using the composite action:

```bash
export TOKEN="your-bearer-token"
export POLL_INTERVAL_SECONDS=5
export MAX_WAIT_SECONDS=1800
./scripts/04-wait-deployment.sh --baseUrl 'https://example.com' --deploymentUuid '...'
```

See `--help` on each script under `scripts/`.
