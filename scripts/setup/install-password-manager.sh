#!/usr/bin/env bash
# shellcheck shell=bash

set -euo pipefail

SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIRECTORY
readonly RELEASE_URL="https://github.com/DopplerHQ/cli/releases/latest"
readonly INSTALL_PATH="/usr/local/bin/doppler"

# shellcheck disable=SC1091
source "$SCRIPT_DIRECTORY/../lib/password-manager.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIRECTORY/../lib/common.sh"

[[ "$(uname -s)" == "Linux" ]] ||
  die "this installer only supports Linux"

require_command curl awk mktemp tar sha256sum install ||
  die "required commands are missing"

distribution="$(get_os_release)"
architecture="$(get_architecture)"
latest_tag="$(latest_release_tag "$RELEASE_URL")" ||
  die "could not determine latest Doppler CLI release"
latest_version="${latest_tag#v}"

if [[ -x "$INSTALL_PATH" ]]; then
  installed_version="$(version_from_binary "$INSTALL_PATH" || true)"

  if [[ "$installed_version" == "$latest_version" ]]; then
    printf 'Doppler CLI %s is already installed system-wide (%s on %s).\n' \
      "$latest_version" "$architecture" "$distribution"
    exit 0
  fi
fi

temporary_directory="$(mktemp -d)" || die "could not create a temporary directory"
trap 'password_manager_cleanup "$temporary_directory"' EXIT

archive_name="doppler_${latest_version}_linux_${architecture}.tar.gz"
archive_url="https://github.com/DopplerHQ/cli/releases/download/${latest_tag}/${archive_name}"
checksum_file="$temporary_directory/checksums.txt"

curl_download \
  --output "$temporary_directory/$archive_name" \
  "$archive_url" ||
  die "could not download Doppler CLI ${latest_version} for ${architecture}"

curl_download \
  --output "$checksum_file" \
  "https://github.com/DopplerHQ/cli/releases/download/${latest_tag}/checksums.txt" ||
  die "could not download Doppler CLI checksums"

expected_checksum="$(awk -v archive="$archive_name" '$2 == archive { print $1; exit }' "$checksum_file")"
actual_checksum="$(sha256sum "$temporary_directory/$archive_name" | awk '{ print $1 }')"

[[ "$expected_checksum" =~ ^[[:xdigit:]]{64}$ ]] ||
  die "no valid checksum found for $archive_name"
[[ "$actual_checksum" == "$expected_checksum" ]] ||
  die "checksum verification failed for $archive_name"

tar -xzf "$temporary_directory/$archive_name" -C "$temporary_directory" ||
  die "could not extract $archive_name"

[[ -x "$temporary_directory/doppler" ]] ||
  die "the Doppler archive does not contain an executable doppler binary"

run_as_root install -Dm755 "$temporary_directory/doppler" "$INSTALL_PATH" ||
  die "could not install Doppler CLI to $INSTALL_PATH"

installed_version="$(version_from_binary "$INSTALL_PATH" || true)"
[[ "$installed_version" == "$latest_version" ]] ||
  die "installed Doppler CLI version does not match ${latest_version}"

printf 'Installed Doppler CLI %s system-wide at %s (%s on %s).\n' \
  "$latest_version" "$INSTALL_PATH" "$architecture" "$distribution"
