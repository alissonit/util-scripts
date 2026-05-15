# GitHub Repo Manager

Manage GitHub repositories via API - set repos to private/public and remove forks.

## What it does

- **Set Privacy**: Changes repository visibility (private or public)
- **Remove Forks**: Deletes repositories that are forks
- **Protected Filter**: Skips repos containing `fiap` or named `alissonit` by default

## Installation

### Prerequisites
```bash
# macOS
brew install curl jq

# Linux (Ubuntu/Debian)
sudo apt-get install curl jq

# Linux (Fedora/RHEL)
sudo dnf install curl jq
```

## Configuration

1. Create a Personal Access Token at: https://github.com/settings/tokens
   - Select scopes: `repo`, `delete_repo`

2. Set the environment variable:
```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

## Usage

### Make all repos private (except protected ones)
```bash
./script.sh --action set-privacy --mode private
```

### Make all repos public (except protected ones)
```bash
./script.sh --action set-privacy --mode public
```

### Delete all forks (except protected ones)
```bash
./script.sh --action remove-forks
```

### Process only protected repos
```bash
# Make "fiap" and "alissonit" repos private
./script.sh --action set-privacy --mode private --protect-only

# Delete forks only from protected repos
./script.sh --action remove-forks --protect-only
```

### Use another username
```bash
./script.sh --action set-privacy --mode private --user other-user
```

## Protected Repos

By default, repos are protected if:
- They contain `fiap` in the name (e.g. `fiap-project`, `my-fiap-repo`)
- They are named exactly `alissonit` (does not affect `alissonit-project`)

## Practical Examples

```bash
# Scenario 1: Make everything private except fiap and alissonit
export GITHUB_TOKEN="your_token"
./script.sh --action set-privacy --mode private

# Scenario 2: Then make the fiap repos public again
./script.sh --action set-privacy --mode public --protect-only

# Scenario 3: Remove forks that are not protected
./script.sh --action remove-forks
```

## Flags

| Flag | Description |
|------|-------------|
| `--action` | `remove-forks` or `set-privacy` (required) |
| `--mode` | `private` or `public` (required for set-privacy) |
| `--protect-only` | Process only protected repos |
| `--user` | GitHub username (default: alissonit) |

## Warnings

⚠️ **CAUTION**:
- `remove-forks` permanently deletes repositories
- Do not interrupt the script with Ctrl+C during execution
- Test with `--protect-only` first
