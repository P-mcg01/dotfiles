# shellcheck shell=bash

# @brief Prints an error message to stderr.
#
# @param $@ Error message to print. At least one argument is required.
# @return 1 Always.
fail() {
  if (($# == 0)); then
    printf 'fail() requires a message\n' >&2
    return 1
  fi

  printf '%s\n' "$*" >&2
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
# At least one command is required.
#
# @return 0 If all commands are available.
# @return 1 1 If no commands are specified or
# any required command is not found.
require_command() {
  local required_command

  if (($# == 0)); then
    fail "at least one command is required"
    return 1
  fi

  for required_command in "$@"; do
    if ! command -v "$required_command" >/dev/null 2>&1; then
      fail "required command not found: $required_command"
      return 1
    fi
  done
}

# @brief Detects the Linux distribution from /etc/os-release.
#
# @param $1 os_release_file Path to os-release file (default: /etc/os-release)
# @return 0 On success.
# @return 1 If the distribution cannot be detected.
get_os_release() {
  local os_release_file="${1:-/etc/os-release}"

  if [[ ! -r "$os_release_file" ]]; then
    fail "os-release file is not readable: $os_release_file"
    return 1
  fi

  # shellcheck disable=SC1090
  source "$os_release_file"

  if [[ -z "${ID:-}" ]]; then
    fail "cannot detect the Linux distribution."
    return 1
  fi

  printf '%s\n' "$ID"
}

# @brief Maps the system architecture to a supported architecture name.
#
# @param $1 arch Architecture string (default: output of uname -m)
# @return 0 On success.
# @return 1 If the architecture is unsupported.
get_architecture() {
  local architecture="${1:-$(uname -m)}"

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

# @brief Returns whether the current user is root.
#
# @return 0 If the current user is root.
# @return 1 Otherwise.
is_root() {
  ((EUID == 0))
}

# @brief Runs a command with root privileges.
#
# @param $@ Command and arguments to execute.
#
# @return 0 If the command succeeds.
# @return non-zero If the command fails, sudo is unavailable,
#         or the script is already running as root.
run_as_root() {
  (($# > 0)) || {
    fail "run_as_root requires a command."
    return 1
  }

  is_root && {
    fail "run_as_root must not be called as root."
    return 1
  }

  require_command sudo || return 1
  sudo "$@"
}
