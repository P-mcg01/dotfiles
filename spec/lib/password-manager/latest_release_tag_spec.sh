# shellcheck shell=bash

Describe 'latest_release_tag()'
  Include scripts/lib/password-manager.sh

  Context 'when curl succeeds'
    It 'returns parsed tag from curl output'
      curl() { printf 'https://github.com/DopplerHQ/cli/releases/tag/v1.2.3\n'; }
      When call latest_release_tag "https://github.com/DopplerHQ/cli/releases/latest"
      The stdout should equal "v1.2.3"
      The status should equal 0
    End
  End

  Context 'when curl fails'
    It 'prints error and returns 1'
      curl() { return 1; }
      When call latest_release_tag "https://github.com/DopplerHQ/cli/releases/latest"
      The stderr should include "could not determine the latest stable Doppler CLI release"
      The status should equal 1
    End
  End

  Context 'when curl returns invalid tag'
    It 'prints error and returns 1'
      curl() { printf 'https://github.com/DopplerHQ/cli/releases/tag/invalid\n'; }
      When call latest_release_tag "https://github.com/DopplerHQ/cli/releases/latest"
      The stderr should include "received an invalid release tag: invalid"
      The status should equal 1
    End
  End
End
