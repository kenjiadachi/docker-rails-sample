#!/bin/bash

set -eu

# Bundlerの依存環境をチェックしておく
bundle check || true

# Yarnの依存関係をcheckしておく
yarn check --integrity --silent || true

# Railsサーバーを立ち上げる場合、PIDファイルがあれば削除しておく
if [ "${1:-}" = rails -a "${2:-}" = server ]; then
  if [ -f tmp/pids/server.pid ]; then
    rm -v tmp/pids/server.pid
  fi
fi

exec "$@"
