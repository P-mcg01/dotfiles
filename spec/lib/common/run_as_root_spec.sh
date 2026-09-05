# shellcheck shell=bash

Describe 'run_as_root()'
  Include scripts/lib/common.sh

  Context 'when not root and sudo available'
    It 'prefixes command with sudo'
      sudo() { printf 'sudo:%s\n' "$*"; }

      When call run_as_root install -m755 foo bar
      The stdout should equal "sudo:install -m755 foo bar"
      The status should equal 0
    End

    It 'propagates command exit code'
      sudo() { return 42; }

      When call run_as_root false
      The status should equal 42
    End
  End

  Context 'when not root and sudo not available'
    It 'prints error and returns 1'
      require_command() {
        echo "required command not found: sudo" >&2
        return 1
      }

      When call run_as_root true
      The stderr should include "required command not found: sudo"
      The status should equal 1
    End
  End

  Context 'when no arguments provided'
    It 'prints error and returns 1'
      When call run_as_root
      The stderr should include "run_as_root requires a command"
      The status should equal 1
    End
  End

  Context 'when running as root'
    It 'prints error and returns 1'
      is_root() { return 0; }

      When call run_as_root true
      The stderr should include "run_as_root must not be called as root"
      The status should equal 1
    End
  End
End
