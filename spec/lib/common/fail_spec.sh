# shellcheck shell=bash

Describe 'fail()'
  Include scripts/lib/common.sh

  It 'prints message to stderr and returns 1'
    When call fail "test error message"
    The stderr should equal "test error message"
    The status should equal 1
  End

  It 'concatenates multiple arguments'
    When call fail "error" "with" "multiple" "args"
    The stderr should equal "error with multiple args"
    The status should equal 1
  End

  It 'handles empty message'
    When call fail
    The stderr should equal "fail() requires a message"
    The status should equal 1
  End
End
