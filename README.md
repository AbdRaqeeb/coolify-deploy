# Deploy via API (GitHub Action)

Composite GitHub Action that deploys an application through a **REST API** compatible with [Coolify](https://coolify.io/) application endpoints: fetch the app, patch `docker_registry_image_tag`, start a deployment, then poll until the deployment reaches a terminal status.

## Usage

Reference the **repository root** (this layout is required for [GitHub Marketplace](https://docs.github.com/en/actions/sharing-automations/creating-actions/publishing-actions-in-github-marketplace)):

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: YOUR_ORG/coolify-deploy@v1
        with:
          app-id: ${{ vars.COOLIFY_APP_ID }}
          image-tag: ${{ github.sha }}
          base-url: ${{ vars.DEPLOY_API_BASE_URL }}
          deploy-api-token: ${{ secrets.DEPLOY_API_TOKEN }}
```

Pin to a **release tag** (for example `v1` or `v1.0.0`), not a moving branch, in real workflows.

### Secrets and variables

| Kind | Suggested name | Purpose |
|------|----------------|--------|
| Secret | `DEPLOY_API_TOKEN` | Bearer token sent as `Authorization: Bearer …` |
| Variable | `DEPLOY_API_BASE_URL` | API origin, no trailing slash (example: `https://coolify.example.com`) |
| Variable | `COOLIFY_APP_ID` | Application UUID in the API |

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `app-id` | yes | — | Application ID in the deploy API |
| `image-tag` | yes | — | Docker image tag to set and deploy |
| `base-url` | yes | — | Base URL of the API (no trailing slash) |
| `deploy-api-token` | yes | — | Bearer token for the API |
| `deploy-use-chmod` | no | `true` | Run `chmod +x` on bundled shell scripts before use |
| `deploy-use-bash` | no | `false` | If `true`, run scripts as `bash script.sh` instead of `./script.sh` |

### Runner requirements

- **bash** and **curl** (standard on `ubuntu-latest`).
- **jq** is required for patching the app, parsing the deploy response, and polling deployment status (`ubuntu-latest` includes `jq`).

### Behavior notes

- If **GET** `/api/v1/applications/{id}` does not return HTTP 200, later steps are skipped (no hard failure on missing app in that step).
- **PATCH** and **POST** deploy expect HTTP 200; non-200 exits the job with an error from the scripts.
- The wait step treats `finished` as success and `error` / `failed` or unexpected statuses as failure. Polling defaults: every **10** seconds, max **3600** seconds (overridable in the shell script via `POLL_INTERVAL_SECONDS` / `MAX_WAIT_SECONDS` if you run scripts manually; the composite action does not expose those as inputs yet).

## Documentation

- [Publishing to GitHub Marketplace](docs/marketplace.md)
- [Configuration reference](docs/configuration.md)
- [HTTP API contract](docs/api.md)

## License

See [LICENSE](LICENSE).

## Security

See [SECURITY.md](SECURITY.md).
