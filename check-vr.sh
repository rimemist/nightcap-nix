#!/usr/bin/env bash
DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/env.sh"
cd "$DIR"
exec "$DIR/build/mocktail-vr-probe" "$@"
