#!/bin/sh

ram_revamped_dir=$(cd "$(dirname "$0")" && pwd)
"${ram_revamped_dir}/bin/ram-revamped" apply
