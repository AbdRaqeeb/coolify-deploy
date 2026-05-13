#!/usr/bin/env bash
set -eu
set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=print-message.sh
source "${SCRIPT_DIR}/print-message.sh"

BASE_URL=''
DEPLOYMENT_UUID=''
TOKEN="${TOKEN:-}"
POLL_INTERVAL_SECONDS="${POLL_INTERVAL_SECONDS:-10}"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-3600}"

DEPLOYMENT_STATUS_FILE="${TMPDIR:-/tmp}/04_deployment_status.json"

print_usage() {
    cat <<'EOF'
Usage: 04-wait-deployment.sh --baseUrl <url> --deploymentUuid <uuid> [options]

Polls GET deployment until status is finished (exit 0) or error/failed / unexpected (exit 1).

Required:
  --baseUrl, --base-url           API base URL
  --deploymentUuid, --deployment-uuid   UUID from deploy response

Options:
  --pollInterval, --poll-interval Seconds between polls (default: 10; or POLL_INTERVAL_SECONDS env)
  --maxWait, --max-wait           Max seconds to wait (default: 3600; or MAX_WAIT_SECONDS env)
  --token                         Bearer token (optional; TOKEN env also works)
  -h, --help                      Show this help

Example:
  04-wait-deployment.sh --baseUrl 'https://api.example.com' --deploymentUuid 'wjvbywya6pnhzl1nqk1ryec9'
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help)
                print_usage
                exit 0
                ;;
            --baseUrl | --base-url)
                BASE_URL="${2:-}"
                shift 2
                ;;
            --baseUrl=* | --base-url=*)
                BASE_URL="${1#*=}"
                shift
                ;;
            --deploymentUuid | --deployment-uuid)
                DEPLOYMENT_UUID="${2:-}"
                shift 2
                ;;
            --deploymentUuid=* | --deployment-uuid=*)
                DEPLOYMENT_UUID="${1#*=}"
                shift
                ;;
            --pollInterval | --poll-interval)
                POLL_INTERVAL_SECONDS="${2:-}"
                shift 2
                ;;
            --pollInterval=* | --poll-interval=*)
                POLL_INTERVAL_SECONDS="${1#*=}"
                shift
                ;;
            --maxWait | --max-wait)
                MAX_WAIT_SECONDS="${2:-}"
                shift 2
                ;;
            --maxWait=* | --max-wait=*)
                MAX_WAIT_SECONDS="${1#*=}"
                shift
                ;;
            --token)
                TOKEN="${2:-}"
                shift 2
                ;;
            --token=*)
                TOKEN="${1#*=}"
                shift
                ;;
            *)
                print_message ERROR "Unknown argument: $1"
                print_usage
                exit 1
                ;;
        esac
    done
}

validate_inputs() {
    if [[ -z "${BASE_URL}" ]]; then
        print_message ERROR "Missing required --baseUrl"
        print_usage
        exit 1
    fi
    if [[ -z "${DEPLOYMENT_UUID}" ]]; then
        print_message ERROR "Missing required --deploymentUuid"
        print_usage
        exit 1
    fi
    if ! [[ "${POLL_INTERVAL_SECONDS}" =~ ^[0-9]+$ ]] || [[ "${POLL_INTERVAL_SECONDS}" -lt 1 ]]; then
        print_message ERROR "poll interval must be a positive integer"
        exit 1
    fi
    if ! [[ "${MAX_WAIT_SECONDS}" =~ ^[0-9]+$ ]] || [[ "${MAX_WAIT_SECONDS}" -lt 1 ]]; then
        print_message ERROR "max wait must be a positive integer"
        exit 1
    fi
}

deployment_get_url() {
    echo "${BASE_URL%/}/api/v1/deployments/${DEPLOYMENT_UUID}"
}

append_curl_auth() {
    local -n _args=$1
    if [[ -n "${TOKEN}" ]]; then
        _args+=(-H "Authorization: Bearer ${TOKEN}")
    fi
}

poll_until_terminal() {
    local url deadline
    url=$(deployment_get_url)
    deadline=$((SECONDS + MAX_WAIT_SECONDS))

    print_message INFO "Polling deployment status: GET ${url}"
    print_message INFO "Poll every ${POLL_INTERVAL_SECONDS}s, timeout ${MAX_WAIT_SECONDS}s"

    while ((SECONDS < deadline)); do
        local code status
        local curl_args=(-sS -H "Accept: application/json")
        append_curl_auth curl_args

        if ! code=$(curl "${curl_args[@]}" -o "${DEPLOYMENT_STATUS_FILE}" -w "%{http_code}" "$url"); then
            print_message WARN "curl failed, retrying in ${POLL_INTERVAL_SECONDS}s"
            sleep "${POLL_INTERVAL_SECONDS}"
            continue
        fi

        if [[ "${code}" != "200" ]]; then
            print_message WARN "GET deployment returned HTTP ${code}, retrying in ${POLL_INTERVAL_SECONDS}s"
            sleep "${POLL_INTERVAL_SECONDS}"
            continue
        fi

        if ! command -v jq >/dev/null 2>&1; then
            print_message ERROR "jq is required to parse deployment status"
            exit 1
        fi

        if [[ ! -s "${DEPLOYMENT_STATUS_FILE}" ]] || ! jq -e . >/dev/null 2>&1 <"${DEPLOYMENT_STATUS_FILE}"; then
            print_message WARN "Empty or invalid JSON, retrying in ${POLL_INTERVAL_SECONDS}s"
            sleep "${POLL_INTERVAL_SECONDS}"
            continue
        fi

        status=$(jq -r '.status // empty' "${DEPLOYMENT_STATUS_FILE}")
        print_message INFO "Deployment status: ${status:-<empty>}"

        case "${status}" in
            finished)
                print_message INFO "Deployment finished successfully."
                return 0
                ;;
            error | failed)
                print_message ERROR "Deployment ended with status: ${status}"
                return 1
                ;;
            in_progress | queued | pending | running | building | starting)
                sleep "${POLL_INTERVAL_SECONDS}"
                ;;
            '')
                print_message WARN "Empty status field, retrying in ${POLL_INTERVAL_SECONDS}s"
                sleep "${POLL_INTERVAL_SECONDS}"
                ;;
            *)
                print_message ERROR "Unexpected deployment status: ${status}"
                return 1
                ;;
        esac
    done

    print_message ERROR "Timed out after ${MAX_WAIT_SECONDS}s waiting for deployment ${DEPLOYMENT_UUID}"
    return 1
}

main() {
    parse_args "$@"
    validate_inputs
    poll_until_terminal
}

main "$@"
