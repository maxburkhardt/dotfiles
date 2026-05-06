#!/bin/sh

fmt_bytes_awk='
function fmt_bytes(bytes) {
  if (bytes >= 1073741824) {
    return sprintf("%.1fG", bytes / 1073741824)
  }
  return sprintf("%dM", bytes / 1048576)
}
'

darwin_stats() {
  {
    /usr/bin/uptime 2>/dev/null
    /usr/bin/memory_pressure -Q 2>/dev/null
    /usr/bin/vm_stat 2>/dev/null
  } | /usr/bin/awk "$fmt_bytes_awk"'
    /load averages:/ {
      load1 = $(NF - 2)
      load5 = $(NF - 1)
      load15 = $NF
      next
    }
    /^The system has/ {
      mem_total = $4
      page_size = $12
      gsub(/[^0-9]/, "", page_size)
      next
    }
    /^Pages free:/ {
      free_pages = $3
      gsub(/\./, "", free_pages)
      next
    }
    /^Pages speculative:/ {
      speculative_pages = $3
      gsub(/\./, "", speculative_pages)
      next
    }
    END {
      mem_free = (free_pages + speculative_pages) * page_size
      mem_used = mem_total - mem_free
      if (mem_used < 0) {
        mem_used = 0
      }
      printf "load %s %s %s | mem %s / %s", load1, load5, load15, fmt_bytes(mem_used), fmt_bytes(mem_total)
    }
  '
}

linux_stats() {
  /usr/bin/awk "$fmt_bytes_awk"'
    BEGIN {
      getline < "/proc/loadavg"
      load1 = $1
      load5 = $2
      load15 = $3
      proc = $4

      while ((getline < "/proc/meminfo") > 0) {
        if ($1 == "MemTotal:") {
          mem_total = $2 * 1024
        } else if ($1 == "MemAvailable:") {
          mem_available = $2 * 1024
        }
      }

      mem_used = mem_total - mem_available
      if (mem_used < 0) {
        mem_used = 0
      }
      printf "load %s %s %s | mem %s / %s | proc %s", load1, load5, load15, fmt_bytes(mem_used), fmt_bytes(mem_total), proc
    }
  '
}

os=${OS:-}
if [ -z "$os" ]; then
  case "$(uname -s)" in
    Darwin) os=darwin ;;
    Linux) os=linux-gnu ;;
  esac
fi

case "$os" in
  darwin)
    darwin_stats
    ;;
  linux-gnu|linux)
    linux_stats
    ;;
esac
