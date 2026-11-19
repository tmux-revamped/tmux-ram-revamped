#!/bin/sh
set -eu

: "${SCREENS_REPO:?}"
demo=/Users/Shared/demo
rm -rf "${demo}"
mkdir -p "${demo}/home" "${demo}/bin" "${demo}/tmux-ram-revamped"
cp -Rpf "${SCREENS_REPO}/bin" "${SCREENS_REPO}/lib" "${SCREENS_REPO}/ram-revamped.tmux" "${demo}/tmux-ram-revamped/"
for tool in tmux gum; do
  tool_path=$(command -v "${tool}")
  ln -s "${tool_path}" "${demo}/bin/${tool}"
done

cat >"${demo}/bin/vm_stat" <<'PAGES'
#!/bin/sh
figures() {
  case "$((($(date +%s) / 5) % 4))" in
  0) free=300000 active=200000 inactive=320000 packed=30000 ;;
  1) free=160000 active=350000 inactive=280000 packed=60000 ;;
  2) free=80000 active=480000 inactive=180000 packed=110000 ;;
  *) free=30000 active=560000 inactive=90000 packed=170000 ;;
  esac
}
printf 'Mach Virtual Memory Statistics: (page size of 16384 bytes)\n'
if [ "${1:-}" = 1 ]; then
  printf '    free   active inactive    wired cmprssor\n'
  while :; do
    figures
    printf '%8s %8s %8s %8s %8s\n' "${free}" "${active}" "${inactive}" 150000 "${packed}"
    sleep 1
  done
fi
figures
printf 'Pages free:                               %s.\n' "${free}"
printf 'Pages active:                             %s.\n' "${active}"
printf 'Pages inactive:                           %s.\n' "${inactive}"
printf 'Pages speculative:                             0.\n'
printf 'Pages wired down:                         150000.\n'
printf 'Pages purgeable:                           20000.\n'
printf 'File-backed pages:                        180000.\n'
printf 'Pages occupied by compressor:             %s.\n' "${packed}"
PAGES

cat >"${demo}/bin/sysctl" <<'SWAP'
#!/bin/sh
case "$((($(date +%s) / 5) % 4))" in
0) used=0.00 ;;
1) used=256.00 ;;
2) used=768.00 ;;
*) used=1536.00 ;;
esac
printf 'vm.swapusage: total = 2048.00M  used = %sM  free = 0.00M  (encrypted)\n' "${used}"
SWAP

cat >"${demo}/bin/ps" <<'PROCESSES'
#!/bin/sh
printf '   4096 tmux\n2097152 postgres\n 786432 node\n'
PROCESSES
chmod +x "${demo}/bin/vm_stat" "${demo}/bin/sysctl" "${demo}/bin/ps"
