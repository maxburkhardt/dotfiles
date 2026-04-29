#!/bin/sh

stats=""
os=${OS:-}
if [ -z "$os" ]; then
  case "$(uname -s)" in
    Darwin) os=darwin ;;
    Linux) os=linux-gnu ;;
  esac
fi

case "$os" in
  linux-gnu|linux)
    awk_os=linux-gnu
    stats=$(top -b -n 1 | head -n 5)
    ;;
  darwin)
    awk_os=darwin
    stats=$(top -R -F -l 1 | head -n 9)
    ;;
  *)
    exit 0
    ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
printf %s "$stats" | awk -f "$script_dir/stats-$awk_os.awk"
