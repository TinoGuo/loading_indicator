#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/prepare_release.sh [patch|minor|major|VERSION] [--dry-run] [--no-fetch]

Prepare the next package release without creating a commit or pushing anything.
The default bump is patch. VERSION may optionally start with "v".

Examples:
  scripts/prepare_release.sh
  scripts/prepare_release.sh minor
  scripts/prepare_release.sh 4.0.2 --dry-run
EOF
}

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

version_is_valid() {
  [[ "$1" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]
}

version_is_greater() {
  local left_major left_minor left_patch
  local right_major right_minor right_patch

  IFS=. read -r left_major left_minor left_patch <<< "$1"
  IFS=. read -r right_major right_minor right_patch <<< "$2"

  if [ "$left_major" -ne "$right_major" ]; then
    [ "$left_major" -gt "$right_major" ]
  elif [ "$left_minor" -ne "$right_minor" ]; then
    [ "$left_minor" -gt "$right_minor" ]
  else
    [ "$left_patch" -gt "$right_patch" ]
  fi
}

versions_are_equal() {
  ! version_is_greater "$1" "$2" && ! version_is_greater "$2" "$1"
}

tag_is_version() {
  local version="${1#v}"
  version_is_valid "$version"
}

tag_version() {
  printf '%s\n' "${1#v}"
}

prefer_tag() {
  local candidate="$1"
  local current="$2"

  if [ -z "$current" ]; then
    return 0
  fi

  if [[ "$candidate" != v* && "$current" == v* ]]; then
    return 0
  fi

  return 1
}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

BUMP_KIND=patch
EXPLICIT_VERSION=
DRY_RUN=0
NO_FETCH=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --no-fetch)
      NO_FETCH=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    patch|minor|major)
      [ -z "$EXPLICIT_VERSION" ] || die 'choose one bump type or one explicit version'
      BUMP_KIND="$1"
      ;;
    v[0-9]*|[0-9]*)
      [ -z "$EXPLICIT_VERSION" ] || die 'only one explicit version is allowed'
      EXPLICIT_VERSION="${1#v}"
      version_is_valid "$EXPLICIT_VERSION" || die "invalid version: $1"
      ;;
    *)
      die "unknown argument: $1 (use --help for usage)"
      ;;
  esac
  shift
done

[ -f pubspec.yaml ] || die 'pubspec.yaml was not found at the repository root'
git rev-parse --show-toplevel >/dev/null 2>&1 || die 'this script must run inside a Git repository'

if ! git diff --quiet -- pubspec.yaml; then
  die 'pubspec.yaml already has local changes; review or commit them before running this script'
fi

if [ "$NO_FETCH" -eq 0 ] && git config --get remote.origin.url >/dev/null 2>&1; then
  git fetch --tags origin || die 'could not refresh origin tags; use --no-fetch only if the local tags are current'
fi

package_version=$(sed -n 's/^version:[[:space:]]*\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)[[:space:]]*$/\1/p' pubspec.yaml | head -n 1)
version_is_valid "$package_version" || die 'could not read a stable three-part version from pubspec.yaml'

latest_tag=
latest_version=
reachable_tag=
reachable_version=

while IFS= read -r tag; do
  tag_is_version "$tag" || continue
  version=$(tag_version "$tag")

  if [ -z "$latest_version" ] || version_is_greater "$version" "$latest_version" || \
    { versions_are_equal "$version" "$latest_version" && prefer_tag "$tag" "$latest_tag"; }; then
    latest_tag="$tag"
    latest_version="$version"
  fi

  tag_commit=$(git rev-parse --verify "${tag}^{commit}" 2>/dev/null) || continue
  if git merge-base --is-ancestor "$tag_commit" HEAD 2>/dev/null; then
    if [ -z "$reachable_version" ] || version_is_greater "$version" "$reachable_version" || \
      { versions_are_equal "$version" "$reachable_version" && prefer_tag "$tag" "$reachable_tag"; }; then
      reachable_tag="$tag"
      reachable_version="$version"
    fi
  fi
done < <(git tag --list)

if [ -n "$latest_version" ] && [ "$latest_version" != "$reachable_version" ]; then
  die "latest tag $latest_tag ($latest_version) is not reachable from HEAD; latest reachable tag is ${reachable_tag:-none}. Update the checkout or repair the tag history before releasing"
fi

previous_tag="$reachable_tag"
base_version="${reachable_version:-$package_version}"

if [ -n "$EXPLICIT_VERSION" ]; then
  next_version="$EXPLICIT_VERSION"
else
  IFS=. read -r base_major base_minor base_patch <<< "$base_version"
  case "$BUMP_KIND" in
    major)
      next_version="$((base_major + 1)).0.0"
      ;;
    minor)
      next_version="${base_major}.$((base_minor + 1)).0"
      ;;
    patch)
      next_version="${base_major}.${base_minor}.$((base_patch + 1))"
      ;;
  esac
fi

version_is_greater "$next_version" "$package_version" || \
  die "next version $next_version must be greater than pubspec.yaml version $package_version"

if [ -n "$latest_version" ]; then
  version_is_greater "$next_version" "$latest_version" || \
    die "next version $next_version must be greater than latest tag $latest_tag"
fi

printf 'Previous reachable release: %s\n' "${previous_tag:-none}"
printf 'Current package version:   %s\n' "$package_version"
printf 'Next package version:      %s\n' "$next_version"

if [ "$DRY_RUN" -eq 1 ]; then
  printf 'Dry run: pubspec.yaml was not changed.\n'
else
  temporary_pubspec=$(mktemp "${TMPDIR:-/tmp}/loading-indicator-pubspec.XXXXXX")
  original_mode=$(stat -f '%Lp' pubspec.yaml 2>/dev/null) || original_mode=$(stat -c '%a' pubspec.yaml)
  cleanup() {
    rm -f "$temporary_pubspec"
  }
  trap cleanup EXIT HUP INT TERM

  awk -v next_version="$next_version" '
    /^version:[[:space:]]*/ && !changed {
      print "version: " next_version
      changed = 1
      next
    }
    { print }
    END {
      if (!changed) exit 1
    }
  ' pubspec.yaml > "$temporary_pubspec" || die 'could not update the version line in pubspec.yaml'

  chmod "$original_mode" "$temporary_pubspec"
  mv "$temporary_pubspec" pubspec.yaml
  trap - EXIT HUP INT TERM
  printf 'Updated pubspec.yaml to %s.\n' "$next_version"
fi

if [ -n "$previous_tag" ]; then
  printf '\nUse this previous tag for generated release notes:\n'
  printf '  gh release create %s --verify-tag --generate-notes --notes-start-tag %s --title %s\n' \
    "$next_version" "$previous_tag" "$next_version"
fi
