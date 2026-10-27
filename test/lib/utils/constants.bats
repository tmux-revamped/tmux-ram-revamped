#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
}

teardown() {
  cleanup_test_environment
}

@test "constants.sh - exposes the plugin version" {
  # Arrange
  unset _TMUX_PLUGIN_CONSTANTS_LOADED

  # Act
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/constants.sh"

  # Assert
  [[ "${RAM_REVAMPED_VERSION}" == "2.0.1" ]] || false
  [[ -n "${TMUX_PLUGIN_DEFAULT_MAX_AGE}" ]] || false
  [[ "${TMUX_PLUGIN_PENDING}" == "..." ]]
}

@test "constants.sh - the source guard is idempotent" {
  unset _TMUX_PLUGIN_CONSTANTS_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/constants.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/constants.sh"
  [[ "${_TMUX_PLUGIN_CONSTANTS_LOADED}" == "1" ]]
}
