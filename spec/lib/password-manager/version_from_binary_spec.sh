# shellcheck shell=bash

Describe 'version_from_binary()'
  Include scripts/lib/password-manager.sh

  Context 'when binary outputs valid version'
    It 'extracts version from "Doppler CLI x.y.z" format'
      doppler() { printf 'Doppler CLI v1.2.3\n'; }
      When call version_from_binary doppler
      The stdout should equal "1.2.3"
      The status should equal 0
    End

    It 'extracts version from "version x.y.z" format'
      doppler() { printf 'version 3.2.1\n'; }
      When call version_from_binary doppler
      The stdout should equal "3.2.1"
      The status should equal 0
    End

    It 'extracts version from output with extra text'
      doppler() { printf 'Doppler CLI 5.6.7 (build abc)\n'; }
      When call version_from_binary doppler
      The stdout should equal "5.6.7"
      The status should equal 0
    End
  End

  Context 'when binary fails'
    It 'prints error and returns 1'
      doppler() { return 1; }
      When call version_from_binary doppler
      The stderr should include "could not query version from binary"
      The status should equal 1
    End
  End

  Context 'when binary succeeds but no version found'
    It 'prints error and returns 1'
      doppler() { printf 'no version here\n'; }
      When call version_from_binary doppler
      The stderr should include "could not determine version from binary"
      The status should equal 1
    End
  End
End
