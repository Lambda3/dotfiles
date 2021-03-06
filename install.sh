#!/usr/bin/env bash

set -euo pipefail

if [ "$EUID" == "0" ]; then
  echo "Please do not run as root"
  exit 2
fi

DOTBOT_DIR="dotbot"
DOTBOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "\e[34mUpdating dotbot submodules.\e[0m"
pushd "$BASEDIR/$DOTBOT_DIR" > /dev/null
git submodule update --init --recursive
popd > /dev/null

echo -e "\e[34mWorking on unpriviledged setup.\e[0m"
"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "$BASEDIR/install.conf.yaml" "${@}"
