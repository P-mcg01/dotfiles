# shellcheck shell=bash

Describe 'install-password-manager.sh'

  SCRIPT="scripts/setup/install-password-manager.sh"

  setup() {
    SANDBOX="$(command mktemp -d)"
    FIXTURE_DIR="$SANDBOX/fixture"
    CALL_LOG="$SANDBOX/calls.log"
    VERSION_QUEUE="$SANDBOX/versions"
    mkdir -p "$FIXTURE_DIR" "$SANDBOX/tmp" "$SANDBOX/bin"
    : > "$CALL_LOG"

    export TMPDIR="$SANDBOX/tmp"
    export DOPPLER_INSTALL_PATH="$SANDBOX/bin/doppler"
  }

  cleanup() {
    rm -rf "$SANDBOX"
  }

  queue_versions() {
    : > "$VERSION_QUEUE"
    local version
    for version in "$@"; do
      printf '%s\n' "$version" >> "$VERSION_QUEUE"
    done
  }

  archive_name() {
    printf 'doppler_%s_linux_%s.tar.gz' "${MOCK_TAG#v}" "$MOCK_ARCH"
  }

  real_hash() {
    sha256sum "$FIXTURE_DIR/archive.tar.gz" | awk '{ print $1 }'
  }

  write_checksums() {
    printf '%s  %s\n' "$(real_hash)" "$(archive_name)" > "$FIXTURE_DIR/checksums.txt"
  }

  build_archive() {
    local content="$FIXTURE_DIR/content"
    rm -rf "$content"
    mkdir -p "$content"

    case "${1:-ok}" in
      ok)
        printf '#!/bin/sh\necho "doppler v1.2.3"\n' > "$content/doppler"
        chmod 755 "$content/doppler"
        ;;
      noexec)
        printf '#!/bin/sh\n' > "$content/doppler"
        chmod 644 "$content/doppler"
        ;;
      missing)
        printf 'readme\n' > "$content/README"
        ;;
    esac

    tar -czf "$FIXTURE_DIR/archive.tar.gz" -C "$content" .
    write_checksums
  }

  corrupt_archive() {
    printf 'this is not a tarball' > "$FIXTURE_DIR/archive.tar.gz"
    write_checksums
  }

  scenario() {
    MOCK_TAG="$1"
    MOCK_ARCH="$2"
    build_archive ok
    queue_versions "${MOCK_TAG#v}"
  }

  make_installed() {
    printf '#!/bin/sh\n' > "$DOPPLER_INSTALL_PATH"
    chmod "${1:-755}" "$DOPPLER_INSTALL_PATH"
  }

  checksums_without_entry() {
    printf '%s  other.tar.gz\n' "$(real_hash)" > "$FIXTURE_DIR/checksums.txt"
  }

  checksums_short() {
    printf 'abc123  %s\n' "$(archive_name)" > "$FIXTURE_DIR/checksums.txt"
  }

  checksums_non_hex() {
    printf '%s  %s\n' "$(printf '%064d' 0 | tr 0 z)" "$(archive_name)" \
      > "$FIXTURE_DIR/checksums.txt"
  }

  checksums_empty() {
    : > "$FIXTURE_DIR/checksums.txt"
  }

  checksums_mismatch() {
    printf '%064d  %s\n' 0 "$(archive_name)" > "$FIXTURE_DIR/checksums.txt"
  }

  checksums_uppercase() {
    printf '%s  %s\n' "$(real_hash | tr 'a-f' 'A-F')" "$(archive_name)" \
      > "$FIXTURE_DIR/checksums.txt"
  }

  checksums_lookalikes_first() {
    {
      printf '%064d  %s.sig\n' 0 "$(archive_name)"
      printf '%064d  x_%s\n' 0 "$(archive_name)"
      printf '%s  %s\n' "$(real_hash)" "$(archive_name)"
    } > "$FIXTURE_DIR/checksums.txt"
  }

  checksums_duplicated() {
    {
      printf '%s  %s\n' "$(real_hash)" "$(archive_name)"
      printf '%064d  %s\n' 0 "$(archive_name)"
    } > "$FIXTURE_DIR/checksums.txt"
  }

  source() {
    case "$1" in
      */lib/*.sh) return 0 ;;
      *) builtin source "$@" ;;
    esac
  }

  die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
  }

  uname() {
    printf '%s\n' "${MOCK_UNAME:-Linux}"
  }

  require_command() {
    printf 'require_command %s\n' "$*" >> "$CALL_LOG"
    if [[ -n "${MOCK_REQUIRE_FAIL:-}" ]]; then
      printf 'required command not found: curl\n' >&2
      return 1
    fi
  }

  get_os_release() {
    if [[ -n "${MOCK_OS_FAIL:-}" ]]; then
      printf 'cannot detect the Linux distribution.\n' >&2
      return 1
    fi
    printf 'debian\n'
  }

  get_architecture() {
    if [[ -n "${MOCK_ARCH_FAIL:-}" ]]; then
      printf 'unsupported architecture: riscv64\n' >&2
      return 1
    fi
    printf '%s\n' "$MOCK_ARCH"
  }

  latest_release_tag() {
    if [[ -n "${MOCK_TAG_FAIL:-}" ]]; then
      printf 'could not determine the latest stable Doppler CLI release\n' >&2
      return 1
    fi
    printf '%s\n' "$MOCK_TAG"
  }

  version_from_binary() {
    local next
    next="$(head -n 1 "$VERSION_QUEUE" 2> /dev/null)" || true
    sed -i '1d' "$VERSION_QUEUE"

    if [[ -z "$next" || "$next" == "FAIL" ]]; then
      printf 'could not query version from binary: %s\n' "$1" >&2
      return 1
    fi
    printf '%s\n' "$next"
  }

  curl_download() {
    local output="" url=""
    while (($# > 0)); do
      case "$1" in
        --output)
          output="$2"
          shift 2
          ;;
        *)
          url="$1"
          shift
          ;;
      esac
    done

    printf 'curl_download %s\n' "$url" >> "$CALL_LOG"

    case "$url" in
      */checksums.txt)
        [[ -z "${MOCK_CHECKSUM_DL_FAIL:-}" ]] || return 22
        cp "$FIXTURE_DIR/checksums.txt" "$output"
        ;;
      *.tar.gz)
        [[ -z "${MOCK_ARCHIVE_DL_FAIL:-}" ]] || return 22
        cp "$FIXTURE_DIR/archive.tar.gz" "$output"
        ;;
    esac
  }

  run_as_root() {
    printf 'run_as_root %s\n' "$*" >> "$CALL_LOG"
    [[ -z "${MOCK_INSTALL_FAIL:-}" ]] || return 1
    "$@"
  }

  mktemp() {
    [[ -z "${MOCK_MKTEMP_FAIL:-}" ]] || return 1
    command mktemp "$@"
  }

  BeforeEach 'setup'
  BeforeEach 'scenario v1.2.3 amd64'
  AfterEach 'cleanup'

  Describe 'preconditions'
    It 'fails on non-Linux systems before checking anything else'
      BeforeRun 'MOCK_UNAME=Darwin'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "this installer only supports Linux"
      The contents of file "$CALL_LOG" should equal ""
    End

    It 'fails when required commands are missing'
      BeforeRun 'MOCK_REQUIRE_FAIL=1'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "required commands are missing"
    End

    It 'checks the exact list of required commands'
      When run source "$SCRIPT"
      The status should be success
      The output should include "Installed Doppler CLI"
      The contents of file "$CALL_LOG" should include \
        "require_command curl awk mktemp tar sha256sum install"
    End

    It 'aborts when the distribution cannot be detected'
      BeforeRun 'MOCK_OS_FAIL=1'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "cannot detect the Linux distribution."
      The contents of file "$CALL_LOG" should not include "curl_download"
    End

    It 'aborts when the architecture is unsupported'
      BeforeRun 'MOCK_ARCH_FAIL=1'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "unsupported architecture"
      The contents of file "$CALL_LOG" should not include "curl_download"
    End
  End

   Describe 'release resolution'
    It 'fails when the latest release cannot be resolved'
      BeforeRun 'MOCK_TAG_FAIL=1'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "could not determine latest Doppler CLI release"
    End

    Context 'tag with "v" prefix'
      BeforeRun 'scenario v1.2.3 amd64'
      It 'strips the prefix for the archive name and keeps it in the URL'
        When run source "$SCRIPT"
        The status should be success
        The output should include "Installed Doppler CLI 1.2.3"
        The contents of file "$CALL_LOG" should include \
          "releases/download/v1.2.3/doppler_1.2.3_linux_amd64.tar.gz"
        The contents of file "$CALL_LOG" should include \
          "releases/download/v1.2.3/checksums.txt"
      End
    End

    Context 'tag without "v" prefix'
      BeforeRun 'scenario 1.2.3 amd64'
      It 'leaves the version untouched'
        When run source "$SCRIPT"
        The status should be success
        The output should include "Installed Doppler CLI 1.2.3"
        The contents of file "$CALL_LOG" should include \
          "releases/download/1.2.3/doppler_1.2.3_linux_amd64.tar.gz"
      End
    End
  End

   Describe 'idempotency'
    It 'exits 0 without downloading when the same version is installed'
      BeforeRun 'make_installed'
      BeforeRun 'queue_versions 1.2.3'
      When run source "$SCRIPT"
      The status should be success
      The output should include \
        "Doppler CLI 1.2.3 is already installed system-wide (amd64 on debian)."
      The contents of file "$CALL_LOG" should not include "curl_download"
      The contents of file "$CALL_LOG" should not include "run_as_root"
    End

    It 'upgrades when a different version is installed'
      BeforeRun 'make_installed'
      BeforeRun 'queue_versions 1.0.0 1.2.3'
      When run source "$SCRIPT"
      The status should be success
      The output should include "Installed Doppler CLI 1.2.3"
      The contents of file "$CALL_LOG" should include "curl_download"
    End

    It 'reinstalls when the installed binary fails to report its version'
      BeforeRun 'make_installed'
      BeforeRun 'queue_versions FAIL 1.2.3'
      When run source "$SCRIPT"
      The status should be success
      The output should include "Installed Doppler CLI 1.2.3"
      The stderr should include "could not query version"
    End

    It 'ignores an install path that is not executable'
      BeforeRun 'make_installed 644'
      BeforeRun 'queue_versions 1.2.3'
      When run source "$SCRIPT"
      The status should be success
      The output should include "Installed Doppler CLI 1.2.3"
    End
   End
 
   Describe 'download'
    It 'fails when the temporary directory cannot be created'
      BeforeRun 'MOCK_MKTEMP_FAIL=1'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "could not create a temporary directory"
    End

    It 'reports version and architecture when the archive download fails'
      BeforeRun 'MOCK_ARCHIVE_DL_FAIL=1'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include \
        "could not download Doppler CLI 1.2.3 for amd64"
    End

    It 'fails when the checksums download fails'
      BeforeRun 'MOCK_CHECKSUM_DL_FAIL=1'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "could not download Doppler CLI checksums"
    End

    Context 'architecture mapping in the archive name'
      Context 'arm64'
        BeforeRun 'scenario v1.2.3 arm64'
        It 'downloads the arm64 build'
          When run source "$SCRIPT"
          The status should be success
          The output should include "(arm64 on debian)"
          The contents of file "$CALL_LOG" should include "doppler_1.2.3_linux_arm64.tar.gz"
        End
      End

      Context 'armv7'
        BeforeRun 'scenario v1.2.3 armv7'
        It 'downloads the armv7 build'
          When run source "$SCRIPT"
          The status should be success
          The output should include "(armv7 on debian)"
          The contents of file "$CALL_LOG" should include "doppler_1.2.3_linux_armv7.tar.gz"
        End
      End

      Context 'armv6'
        BeforeRun 'scenario v1.2.3 armv6'
        It 'downloads the armv6 build'
          When run source "$SCRIPT"
          The status should be success
          The output should include "(armv6 on debian)"
          The contents of file "$CALL_LOG" should include "doppler_1.2.3_linux_armv6.tar.gz"
        End
      End
     End
   End
 
   Describe 'checksum verification'
    It 'rejects checksums.txt without an entry for the archive'
      BeforeRun 'checksums_without_entry'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "no valid checksum found for doppler_1.2.3_linux_amd64.tar.gz"
    End

    It 'rejects a checksum shorter than 64 characters'
      BeforeRun 'checksums_short'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "no valid checksum found"
    End

    It 'rejects a checksum with non-hexadecimal characters'
      BeforeRun 'checksums_non_hex'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "no valid checksum found"
    End

    It 'rejects an empty checksums.txt'
      BeforeRun 'checksums_empty'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "no valid checksum found"
    End

    It 'rejects a well-formed checksum that does not match the archive'
      BeforeRun 'checksums_mismatch'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include \
        "checksum verification failed for doppler_1.2.3_linux_amd64.tar.gz"
    End

    It 'fails verification when the expected checksum is uppercase'
      BeforeRun 'checksums_uppercase'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "checksum verification failed"
    End

    It 'matches the archive name exactly, ignoring look-alike entries'
      BeforeRun 'checksums_lookalikes_first'
      When run source "$SCRIPT"
      The status should be success
      The output should include "Installed Doppler CLI 1.2.3"
    End

    It 'uses the first entry when the archive is listed twice'
      BeforeRun 'checksums_duplicated'
      When run source "$SCRIPT"
      The status should be success
      The output should include "Installed Doppler CLI 1.2.3"
    End
   End

  Describe 'extraction'
    It 'fails when the archive cannot be extracted'
      BeforeRun 'corrupt_archive'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "could not extract doppler_1.2.3_linux_amd64.tar.gz"
    End

    It 'fails when the archive has no doppler binary'
      BeforeRun 'build_archive missing'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "does not contain an executable doppler binary"
    End

    It 'fails when the doppler binary is not executable'
      BeforeRun 'build_archive noexec'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "does not contain an executable doppler binary"
    End
   End

  Describe 'installation'
    It 'fails when the installation command fails'
      BeforeRun 'MOCK_INSTALL_FAIL=1'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "could not install Doppler CLI to $DOPPLER_INSTALL_PATH"
    End

    It 'installs with mode 755 into the configured path'
      When run source "$SCRIPT"
      The status should be success
      The output should include "Installed Doppler CLI"
      The contents of file "$CALL_LOG" should include "run_as_root install -Dm755"
      The contents of file "$CALL_LOG" should include "/doppler $DOPPLER_INSTALL_PATH"
    End

    It 'fails when the installed binary cannot report its version'
      BeforeRun 'queue_versions FAIL'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "installed Doppler CLI version does not match 1.2.3"
    End

    It 'fails when the installed version differs from the expected one'
      BeforeRun 'queue_versions 9.9.9'
      When run source "$SCRIPT"
      The status should be failure
      The stderr should include "installed Doppler CLI version does not match 1.2.3"
    End

    It 'completes a clean installation'
      When run source "$SCRIPT"
      The status should be success
      The output should equal \
        "Installed Doppler CLI 1.2.3 system-wide at $DOPPLER_INSTALL_PATH (amd64 on debian)."
      The path "$DOPPLER_INSTALL_PATH" should be executable
    End
  End
End
