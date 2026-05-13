# HTTP API contract

This action is built for APIs that behave like Coolify’s **v1** application and deployment routes. Your server must expose the same paths and shapes (status strings may vary slightly; see the wait script for accepted values).

## Endpoints

### 1. Get application

- **Method / URL:** `GET {base-url}/api/v1/applications/{app-id}`
- **Headers:** `Authorization: Bearer <token>` (if token is set)
- **Success:** HTTP **200** with JSON body containing at least `name` and `docker_registry_image_tag` (optional for the action logic; used for logs when `jq` is present).

### 2. Update Docker image tag

- **Method / URL:** `PATCH {base-url}/api/v1/applications/{app-id}`
- **Headers:** `Authorization`, `Content-Type: application/json`, `Accept: application/json`
- **Body:** `{"docker_registry_image_tag":"<image-tag>"}` (built with `jq`)
- **Success:** HTTP **200**

### 3. Start deployment

- **Method / URL:** `POST {base-url}/api/v1/applications/{app-id}/start`
- **Headers:** `Authorization`, `Accept: application/json`
- **Success:** HTTP **200** with JSON containing `deployment_uuid` (required for the next step).

### 4. Poll deployment

- **Method / URL:** `GET {base-url}/api/v1/deployments/{deployment_uuid}`
- **Headers:** `Authorization`, `Accept: application/json`
- **Success polling:** HTTP **200** with JSON containing a `status` field.

#### Status handling (`04-wait-deployment.sh`)

| `status` value | Result |
|----------------|--------|
| `finished` | Success, script exits 0 |
| `error`, `failed` | Failure, script exits 1 |
| `in_progress`, `queued`, `pending`, `running`, `building`, `starting` | Continue polling |
| Empty | Retry |
| Any other value | Treated as unexpected → failure |

If your API uses different status strings, fork or extend `scripts/04-wait-deployment.sh` and map them into the cases above.

## Compatibility disclaimer

Coolify and third-party APIs evolve independently. Confirm path and JSON fields against your installed version before relying on this action in production.
