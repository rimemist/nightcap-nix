#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
nix develop --command bash -c "cmake -B build -G Ninja -DMOCKTAIL_ENABLE_VR=ON -DBUILD_TESTING=OFF && cmake --build build"
