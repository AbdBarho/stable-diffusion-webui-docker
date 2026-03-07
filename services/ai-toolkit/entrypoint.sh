#!/usr/bin/env bash
# get envs files and export envars
export $(egrep  -v '^#'  /run/secrets/* | xargs)
# if need some specific file, where password is the secret name
# export $(egrep  -v '^#'  /run/secrets/password| xargs)
# call the dockerfile's entrypoint
source /start.sh
