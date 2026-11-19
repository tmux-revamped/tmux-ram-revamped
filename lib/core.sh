#!/bin/sh
# shellcheck disable=SC2034

[ -n "${RAM_REVAMPED_CORE_LOADED:-}" ] && return 0
RAM_REVAMPED_CORE_LOADED=1

readonly RAM_REVAMPED_VERSION="3.0.0"
