#!/bin/sh

hyperlink=${TMUX_MOUSE_HYPERLINK:-}
line=${TMUX_MOUSE_LINE:-}
x=${TMUX_MOUSE_X:-0}

open_url() {
    case "$1" in
        [hH][tT][tT][pP]://*|[hH][tT][tT][pP][sS]://*)
            open -u "$1" >/dev/null 2>&1 &
            exit 0
            ;;
    esac
}

if [ -n "$hyperlink" ]; then
    open_url "$hyperlink"
fi

url=$(
    TMUX_MOUSE_X="$x" perl -CS -ne '
        chomp;
        my $x = $ENV{"TMUX_MOUSE_X"} // 0;
        while (m{((?:https?)://[^\s<>"'\''{}]+)}gi) {
            my ($start, $end, $url) = ($-[1], $+[1], $1);
            $url =~ s/[),.;:!?]+$//;
            if ($x >= $start - 1 && $x <= $end + 1) {
                print $url;
                exit;
            }
        }
    ' <<EOF
$line
EOF
)

if [ -n "$url" ]; then
    open_url "$url"
fi

exit 1
