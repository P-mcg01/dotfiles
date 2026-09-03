# shellcheck shell=bash

# @brief Prints an error message to stderr.
#
# @param $@ Message error to print.
# @return 1 Always.
fail() {
  printf 'Error: %s\n' "$*" >&2
  return 1
}

# @brief Prints an error message and exits with a failure status.
#
# @param $@ Error message to print.
die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

# @brief Checks that all required commands are available.
#
# @param $@ required_command Commands to check.
#
# @return 0 If all commands are available.
# @return 1 If any command is not found.
require_command() {
  local required_command

  for required_command in "$@"; do
    if ! command -v "$required_command" >/dev/null 2>&1; then
      fail "required command not found: $required_command"
      return 1
    fi
  done
}

# @brief Detects the Linux distribution from /etc/os-release.
#
# @return 0 On success.
# @return 1 If the distribution cannot be detected.
get_os_release() {
  if [[ ! -r "/etc/os-release" ]]; then
    fail "cannot detect the Linux distribution."
    return 1
  fi

  # shellcheck disable=SC1091
  source /etc/os-release

  if [[ -z "${ID:-}" ]]; then
    fail "cannot detect the Linux distribution."
    return 1
  fi

  printf '%s\n' "$ID"
}

# @brief Maps the system architecture to a supported architecture name.
#
# @return 0 On success.
# @return 1 If the architecture is unsupported.
get_architecture() {
  local architecture

  architecture="$(uname -m)"

  case "$architecture" in
  x86_64)
    printf '%s\n' "amd64"
    ;;
  aarch64 | arm64)
    printf '%s\n' "arm64"
    ;;
  armv7l | armv7)
    printf '%s\n' "armv7"
    ;;
  armv6l | armv6)
    printf '%s\n' "armv6"
    ;;
  *)
    fail "unsupported architecture: $architecture"
    return 1
    ;;
  esac
}

# @brief Runs a command with root privileges.
#
# @param $@ command Command and arguments to execute.
#
# @return 0 If the command succeeds.
# @return non-zero If the command fails or sudo is unavailable.
run_as_root() {
  (($# > 0)) || {
    fail "run_as_root requires a command."
    return 1
  }

  if ((EUID == 0)); then
    "$@"
  else
    require_command sudo || return 1
    sudo "$@"
  fi
}
