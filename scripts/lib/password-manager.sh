# shellcheck shell=bash

# shellcheck disable=SC1091
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# @brief Extracts and validates a release tag from a URL.
#
# @param $1 release_url Url containing the release tag.
# @return non-zero If the release tag is invalid.
release_tag_from_url() {
  local release_url="$1"

  release_url="${release_url%/}"
  release_url="${release_url##*/}"

  if [[ ! "$release_url" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    fail "received an invalid release tag: $release_url"
    return 1
  fi

  printf '%s\n' "$release_url"
}

# @brief Resolves the latest stable release tag from a release url.
#
# @param $1 release_url Url to the latest release.
# @return non-zero If the release URL cannot be resolved.
latest_release_tag() {
  local release_url="$1"
  local release_url_resolved

  if ! release_url_resolved="$(
    curl \
      --fail \
      --silent \
      --show-error \
      --location \
      --retry 3 \
      --connect-timeout 10 \
      --max-time 120 \
      --proto '=https' \
      --tlsv1.2 \
      --output /dev/null \
      --write-out '%{url_effective}' \
      "$release_url"
  )"; then
    fail "could not determine the latest stable Doppler CLI release"
    return 1
  fi

  release_tag_from_url "$release_url_resolved"
}

# @brief Extracts the semantic version from a binary's output.
#
# @param $1 Binary path to the binary to query.
# @return non-zero If the binary fails or no valid version is found.
version_from_binary() {
  local version_output

  version_output="$("$1" --version 2>/dev/null)" || {
    fail "could not query version from binary: $1"
    return 1
  }

  if [[ "$version_output" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  else
    fail "could not determine version from binary: $1"
    return 1
  fi
}

# @brief Downloads a resource using curl with predefined options.
#
# @param $@ Arguments passed directly to curl.
# @return curl's exit status.
curl_download() {
  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --connect-timeout 10 \
    --max-time 120 \
    --proto '=https' \
    --tlsv1.2 \
    "$@"
}
