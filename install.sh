#!/usr/bin/env bash

SCRIPT_PATH="$0"
SCRIPT_FILE="${SCRIPT_PATH##*/}"
SCRIPT_NAME="${SCRIPT_FILE%.*}"
SCRIPT_DIR="${SCRIPT_PATH%/*}"
SCRIPT_REALPATH="$(readlink -f "$SCRIPT_PATH")"
SCRIPT_REALFILE="${SCRIPT_REALPATH##*/}"
SCRIPT_REALNAME="${SCRIPT_REALFILE%.*}"
SCRIPT_REALDIR="${SCRIPT_REALPATH%/*}"

INSTALL="$(lsb_release -si|tr 'A-Z' 'a-z')/$(lsb_release -sr)/install.sh"

if [ ! -x "$SCRIPT_REALDIR/$INSTALL" ]; then
  echo -e "\e[31;1mError:\e[0m Install script is not found: $INSTALL"
  exit 1
fi >&2

"$SCRIPT_REALDIR/$INSTALL"
