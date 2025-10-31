#!/bin/bash
# macOS-specific build script for hamt-bench
# Requires bdw-gc installed via Homebrew: brew install bdw-gc

set -e  # Exit on error

# Check if brew is available
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Check if bdw-gc is installed
if ! brew list bdw-gc &> /dev/null; then
    echo "Error: bdw-gc not installed. Installing now..."
    brew install bdw-gc
fi

# Get bdw-gc prefix
BDW_GC_PREFIX=$(brew --prefix bdw-gc)

echo "Building hamt-bench with bdw-gc from: $BDW_GC_PREFIX"

# Build with proper flags for macOS
make CFLAGS="-g -O2 -I$BDW_GC_PREFIX/include" LDFLAGS="-L$BDW_GC_PREFIX/lib"

echo "Build complete! Binary available at: build/bench-hamt"
