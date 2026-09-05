# shellcheck shell=bash

Describe 'get_architecture()'
  Include scripts/lib/common.sh

  Context 'known architectures'
    Parameters
      x86_64 amd64
      aarch64 arm64
      arm64 arm64
      armv7l armv7
      armv7 armv7
      armv6l armv6
      armv6 armv6
    End

    It 'maps $1 to $2'
      When call get_architecture "$1"
      The stdout should equal "$2"
      The status should equal 0
    End
  End

  Context 'unknown architecture'
    It 'prints error and returns 1'
      When call get_architecture "unknownarch"
      The stderr should include "unsupported architecture: unknownarch"
      The status should equal 1
    End
  End
End
