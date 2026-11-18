#!/usr/bin/env bash
set -e
DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/env.sh"
export MOCKTAIL_VR_ENABLED=1
cd "$DIR"
exec "$DIR/build/mocktail" --vr "$@"
