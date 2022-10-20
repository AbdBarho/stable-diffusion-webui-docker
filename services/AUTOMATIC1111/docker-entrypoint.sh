#!/bin/sh
# vim:sw=4:ts=4:et

set -e

ENTRYPOINT_DIR="/docker/docker-entrypoint.d/"

if /usr/bin/find "$ENTRYPOINT_DIR" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo "$0: $ENTRYPOINT_DIR is not empty, will attempt to perform configuration"

    echo "$0: Looking for shell scripts in $ENTRYPOINT_DIR"
    find "$ENTRYPOINT_DIR" -follow -type f -print | sort -V | while read -r f; do
    case "$f" in
        *.sh)
            if [ -x "$f" ]; then
                echo "$0: Launching $f";
                "$f"
            else
                # warn on shell scripts without exec bit
                echo "$0: Ignoring $f, not executable";
            fi
            ;;
        *) echo "$0: Ignoring $f";;
    esac
done

echo "$0: Configuration complete; ready for start up"
else
    echo "$0: No files found in $ENTRYPOINT_DIR, skipping configuration"
fi

exec "$@"
