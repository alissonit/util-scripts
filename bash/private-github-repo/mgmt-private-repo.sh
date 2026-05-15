#!/usr/bin/env bash
set -euo pipefail

USERNAME="alissonit"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
ACTION=""
MODE="private"
PROTECT_ONLY=false
protected_pattern='(fiap|^alissonit$)'

usage() {
  cat <<EOF
Usage: $0 --action remove-forks|set-privacy [--mode private|public] [--protect-only] [--user USERNAME]

Options:
  --action remove-forks|set-privacy   Choose the action
  --mode private|public               Required when action is set-privacy
  --protect-only                      Process only repos matching protected pattern
  --user USERNAME                     GitHub username (default: alissonit)
EOF
  exit 1
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --action)
        ACTION="${2:-}"
        shift 2
        ;;
      --mode)
        MODE="${2:-}"
        shift 2
        ;;
      --protect-only)
        PROTECT_ONLY=true
        shift
        ;;
      --user)
        USERNAME="${2:-}"
        shift 2
        ;;
      *)
        usage
        ;;
    esac
  done

  if [[ -z "$ACTION" ]]; then
    usage
  fi

  if [[ "$ACTION" != "remove-forks" && "$ACTION" != "set-privacy" ]]; then
    usage
  fi

  if [[ "$ACTION" == "set-privacy" && "$MODE" != "private" && "$MODE" != "public" ]]; then
    usage
  fi

  if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "ERROR: set the GITHUB_TOKEN environment variable"
    exit 1
  fi
}

fetch_repos() {
  curl -sS -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/user/repos?per_page=100"
}

select_repos() {
  local repos_json="$1"
  if [[ "$PROTECT_ONLY" == true ]]; then
    jq -r --arg pattern "$protected_pattern" \
      '.[] | select(.name | test($pattern; "i")) | .name' <<< "$repos_json"
  else
    jq -r --arg pattern "$protected_pattern" \
      '.[] | select((.name | test($pattern; "i")) | not) | .name' <<< "$repos_json"
  fi
}

select_forks() {
  local repos_json="$1"
  if [[ "$PROTECT_ONLY" == true ]]; then
    jq -r --arg pattern "$protected_pattern" \
      '.[] | select(.fork == true and (.name | test($pattern; "i"))) | .name' <<< "$repos_json"
  else
    jq -r --arg pattern "$protected_pattern" \
      '.[] | select(.fork == true and (.name | test($pattern; "i") | not)) | .name' <<< "$repos_json"
  fi
}

remove_forks() {
  local repos_json="$1"
  local repos
  repos="$(select_forks "$repos_json")"

  if [[ -z "$repos" ]]; then
    echo "No forks to remove."
    return
  fi

  while IFS= read -r repo; do
    echo "Deleting fork: $repo"
    curl -sS -X DELETE \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$USERNAME/$repo"
  done <<< "$repos"
}

set_privacy() {
  local repos_json="$1"
  local repos
  repos="$(select_repos "$repos_json")"

  if [[ -z "$repos" ]]; then
    echo "No repositories to update."
    return
  fi

  local private_value=true
  if [[ "$MODE" == "public" ]]; then
    private_value=false
  fi

  while IFS= read -r repo; do
    echo "Setting $repo to $MODE"
    curl -sS -X PATCH \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$USERNAME/$repo" \
      -d "{\"private\":$private_value}"
  done <<< "$repos"
}

main() {
  parse_args "$@"

  local repos_json
  repos_json="$(fetch_repos)"

  if [[ -z "$repos_json" ]]; then
    echo "ERROR: failed to fetch repositories"
    exit 1
  fi

  case "$ACTION" in
    remove-forks)
      remove_forks "$repos_json"
      ;;
    set-privacy)
      set_privacy "$repos_json"
      ;;
  esac
}

main "$@"