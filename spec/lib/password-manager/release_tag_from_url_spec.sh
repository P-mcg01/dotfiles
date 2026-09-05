# shellcheck shell=bash

Describe 'release_tag_from_url()'
  Include scripts/lib/password-manager.sh

  Context 'valid semver with v prefix'
    It 'extracts tag from URL with tag as last component'
      When call release_tag_from_url "https://github.com/DopplerHQ/cli/releases/tag/v1.2.3"
      The stdout should equal "v1.2.3"
      The status should equal 0
    End

    It 'extracts tag from URL with trailing slash'
      When call release_tag_from_url "https://github.com/DopplerHQ/cli/releases/download/v1.2.3/"
      The stdout should equal "v1.2.3"
      The status should equal 0
    End
  End

  Context 'valid semver without v prefix'
    It 'extracts tag from URL'
      When call release_tag_from_url "https://github.com/DopplerHQ/cli/releases/tag/1.2.3"
      The stdout should equal "1.2.3"
      The status should equal 0
    End
  End

  Context 'invalid tag formats'
    It 'fails on non-semver tag'
      When call release_tag_from_url "https://github.com/DopplerHQ/cli/releases/tag/latest"
      The stderr should include "received an invalid release tag: latest"
      The status should equal 1
    End

    It 'fails on incomplete version'
      When call release_tag_from_url "https://github.com/DopplerHQ/cli/releases/tag/v1.2"
      The stderr should include "received an invalid release tag: v1.2"
      The status should equal 1
    End

    It 'fails on empty tag'
      When call release_tag_from_url "https://github.com/DopplerHQ/cli/releases/tag/"
      The stderr should include "received an invalid release tag:"
      The status should equal 1
    End

    It 'fails on malformed version'
      When call release_tag_from_url "https://github.com/DopplerHQ/cli/releases/tag/v1.2.3-beta"
      The stderr should include "received an invalid release tag: v1.2.3-beta"
      The status should equal 1
    End
  End
End