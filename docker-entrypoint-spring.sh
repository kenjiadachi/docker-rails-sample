#!/bin/bash

set -eu

# Springのサブコマンドやオプションから始まる場合、springコマンドを経由させる
case "${1:-}" in
  binstub | help | server | status | stop | "-*" )
    set -- spring "$@"
    ;;
esac

# Springサーバーを立ち上げる場合、socketファイルを削除しておく
if [ "${1:-}" = spring -a "${2:-}" = server ]; then
  if [ -n "${SPRING_SOCKET}" -a -S "${SPRING_SOCKET}" ]; then
    rm -v "${SPRING_SOCKET}"
  fi
fi

exec "$@"
