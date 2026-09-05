# shellcheck shell=bash

Describe 'require_command()'
  Include scripts/lib/common.sh

  Context 'when all commands exist'
    It 'returns 0'
      When call require_command true false
      The status should equal 0
    End
  End

  Context 'when one command is missing'
    It 'prints error and returns 1'
      When call require_command true nonexistent_command_xyz false
      The stderr should include "required command not found: nonexistent_command_xyz"
      The status should equal 1
    End
  End

  Context 'when multiple commands are missing'
    It 'fails on first missing command'
      When call require_command nonexistent_a nonexistent_b
      The stderr should include "required command not found: nonexistent_a"
      The status should equal 1
    End
  End

  Context 'when no arguments provided'
    It 'print error and returns 1'
      When call require_command
      The stderr should include "at least one command is required"
      The status should equal 1
    End
  End
End
