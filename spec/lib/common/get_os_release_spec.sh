# shellcheck shell=bash

Describe 'get_os_release()'
  Include scripts/lib/common.sh

  Context 'with valid os-release file'
    It 'returns the ID'
      temp_file=$(mktemp)
      printf 'ID=fedora\n' > "$temp_file"
      When call get_os_release "$temp_file"
      The stdout should equal "fedora"
      The status should equal 0
      rm -f "$temp_file"
    End

    It 'handles ID with quotes'
      temp_file=$(mktemp)
      printf 'ID="ubuntu"\n' > "$temp_file"
      When call get_os_release "$temp_file"
      The stdout should equal "ubuntu"
      The status should equal 0
      rm -f "$temp_file"
    End
  End

  Context 'when file does not exist'
    It 'prints error and returns 1'
      When call get_os_release "/nonexistent/os-release"
      The stderr should include "os-release file is not readable: $temp_file"
      The status should equal 1
    End
  End

  Context 'when file exists but is unreadable'
    It 'prints error and returns 1'
      temp_file=$(mktemp)
      chmod 000 "$temp_file"
      When call get_os_release "$temp_file"
      The stderr should include "os-release file is not readable: $temp_file"
      The status should equal 1
      chmod 644 "$temp_file"
      rm -f "$temp_file"
    End
  End

  Context 'when file exists but has no ID'
    It 'prints error and returns 1'
      temp_file=$(mktemp)
      printf 'NAME="Test"\n' > "$temp_file"
      When call get_os_release "$temp_file"
      The stderr should include "cannot detect the Linux distribution"
      The status should equal 1
      rm -f "$temp_file"
    End
  End
End
