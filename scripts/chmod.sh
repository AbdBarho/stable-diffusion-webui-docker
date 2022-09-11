#!/bin/bash

set -e

find . -name "*.sh" -exec git update-index --chmod=+x {} \;
