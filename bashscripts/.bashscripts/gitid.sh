#!/bin/bash
# ~/.bashscripts/gitid.sh

gitid() {
  local REPO_URL=""
  local NAME=""
  local EMAIL=""
  local USERNAME=""

  # Parse flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        echo "Usage: gitid --url <repo-url> --name <name> --email <email> --username <username>"
        echo ""
        echo "Options:"
        echo "  --url       HTTPS git remote URL"
        echo "  --name      Git user name"
        echo "  --email     Git user email"
        echo "  --username  GitHub username for credential scoping"
        echo "  -h, --help  Show this help message"
        echo ""
        echo "Example:"
        echo "  gitid --url https://github.com/khan-asfi-reza/khanasfireza.dev.git --name \"khan asfi reza\" --email khanasfireza10@gmail.com --username khan-asfi-reza"
        return 0
        ;;
      --url)      REPO_URL="$2"; shift 2 ;;
      --name)     NAME="$2";     shift 2 ;;
      --email)    EMAIL="$2";    shift 2 ;;
      --username) USERNAME="$2"; shift 2 ;;
      *)
        echo "Error: unknown option '$1'"
        echo "Run 'gitid --help' for usage"
        return 1
        ;;
    esac
  done

  # Validate all required
  local errors=()
  [ -z "$REPO_URL" ]  && errors+=("  --url is required")
  [ -z "$NAME" ]      && errors+=("  --name is required")
  [ -z "$EMAIL" ]     && errors+=("  --email is required")
  [ -z "$USERNAME" ]  && errors+=("  --username is required")

  if [ ${#errors[@]} -gt 0 ]; then
    echo "Error: missing required arguments:"
    for err in "${errors[@]}"; do echo "$err"; done
    echo "Run 'gitid --help' for usage"
    return 1
  fi

  git remote set-url origin "$REPO_URL"
  git config user.name "$NAME"
  git config user.email "$EMAIL"
  git config "credential.${REPO_URL}.username" "$USERNAME"

  echo "✓ $USERNAME <$EMAIL> → $REPO_URL"
}
