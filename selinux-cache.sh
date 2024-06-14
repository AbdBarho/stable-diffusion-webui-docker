#!/bin/bash

# This script fixes selinux blocking file access to the pip and apt mount cache
# on container builds after the first one. This file uses "Z" instead of "z"
# because sometimes the shared label does not always get applied to every file.
# "Z" will force all files to be accessable by the current build step, fixing
# the "file not found" issue.

# WARNING: DON'T RUN THIS FOR NOW!
# TODO: INTEGRATE THIS SCRIPT SOMEHOW FOR DOCKER COMPATIBILITY

disabled_pip="/root/.cache/pip "
enabled_pip="/root/.cache/pip,Z "
disabled_apt="/var/cache/apt "
enabled_apt="/var/cache/apt,Z "

for file in ./services/*/Dockerfile; do
    if [[ "$1" == "--disable" ]]; then
        sed -i "s|$enabled_pip|$disabled_pip|g" "$file"
        sed -i "s|$enabled_apt|$disabled_apt|g" "$file"
        echo "Disabled selinux relabeling for cache in $file."
    else
        sed -i "s|$disabled_pip|$enabled_pip|g" "$file"
        sed -i "s|$disabled_apt|$enabled_apt|g" "$file"
        echo "Enabled selinux relabeling for cache in $file."
    fi
done
