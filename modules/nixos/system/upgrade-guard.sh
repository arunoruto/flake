# ExecCondition of nixos-upgrade: exit 0 lets the upgrade run, exit 1 skips it
# cleanly. Runs only if the commit the running system was built from is
# already on $BRANCH, so an upgrade never rolls back an unpushed deploy.
#
# Env: REPO (owner/name), BRANCH, HOST. Every skip is pushed to the ntfy URL
# in $CREDENTIALS_DIRECTORY/ntfy. Overridable for tests: NIXOS_VERSION,
# GITHUB_API.

notify() {
  local url_file="${CREDENTIALS_DIRECTORY:-}/ntfy"
  if [[ ! -r $url_file ]]; then
    echo "no ntfy credential, not notifying" >&2
    return 0
  fi
  curl -fsS --max-time 20 -H "Title: nixos-upgrade skipped on $HOST" -H "Tags: warning" \
    -d "$1" "$(<"$url_file")" >/dev/null || echo "ntfy notification failed" >&2
}

skip() {
  echo "skipping upgrade: $1"
  notify "$1"
  exit 1
}

if ! rev=$("${NIXOS_VERSION:-/run/current-system/sw/bin/nixos-version}" --configuration-revision); then
  echo "running system has no configuration revision, upgrading"
  exit 0
fi

if [[ $rev == *-dirty ]]; then
  skip "running system was built from uncommitted changes ($rev). Commit, push and deploy to resume upgrades."
fi

url="${GITHUB_API:-https://api.github.com}/repos/$REPO/compare/$BRANCH...$rev"
if ! response=$(curl -sS --max-time 30 -H "Accept: application/vnd.github+json" -w '\n%{http_code}' "$url" 2>&1); then
  skip "GitHub API unreachable: $response"
fi
code=${response##*$'\n'}
body=${response%$'\n'*}

case $code in
  200) ;;
  404) skip "running commit $rev is not on GitHub (never pushed?)." ;;
  *) skip "GitHub API answered HTTP $code for $url" ;;
esac

status=$(jq -r .status <<<"$body") || skip "unparsable GitHub API response for $url"
case $status in
  identical | behind)
    echo "running commit $rev is on $BRANCH ($status), upgrading"
    exit 0
    ;;
  ahead | diverged) skip "running commit $rev is $status of $BRANCH: it has unpushed commits. Push them to resume upgrades." ;;
  *) skip "unexpected compare status '$status' for $rev" ;;
esac
