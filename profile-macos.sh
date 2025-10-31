#!/bin/bash
# macOS Instruments profiling script for libhamt
# This script builds the benchmark with debug symbols and runs Instruments

set -e

# Configuration
BINARY="build/bench-hamt"
TEMPLATE="${1:-Time Profiler}"  # Default to Time Profiler, can override with arg
OUTPUT_DIR="profiles"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TRACE_FILE="${OUTPUT_DIR}/libhamt_${TIMESTAMP}.trace"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Check if Instruments is available
if ! command -v xctrace &> /dev/null; then
    echo "Error: xctrace (Instruments CLI) not found."
    echo "Please install Xcode Command Line Tools."
    exit 1
fi

# Check if bdw-gc is installed
if ! command -v brew &> /dev/null || ! brew list bdw-gc &> /dev/null; then
    echo "Error: bdw-gc not installed. Run: brew install bdw-gc"
    exit 1
fi

# Get bdw-gc prefix
BDW_GC_PREFIX=$(brew --prefix bdw-gc)

echo "Building libhamt benchmark with debug symbols..."
# Build with -g for debug symbols, keep -O2 for realistic profiling
make clean
make CFLAGS="-g -O2 -I$BDW_GC_PREFIX/include" LDFLAGS="-L$BDW_GC_PREFIX/lib"

if [ ! -f "${BINARY}" ]; then
    echo "Error: Build failed, ${BINARY} not found"
    exit 1
fi

echo ""
echo "Starting Instruments profiling..."
echo "Template: ${TEMPLATE}"
echo "Output: ${TRACE_FILE}"
echo ""

# Run Instruments
# Available templates: "Time Profiler", "Allocations", "Leaks", "System Trace", etc.
# To list all templates: xctrace list templates
xctrace record --template "${TEMPLATE}" --output "${TRACE_FILE}" --launch -- "${BINARY}"

echo ""
echo "Profiling complete!"
echo "Trace file saved to: ${TRACE_FILE}"
echo ""
echo "To view the trace:"
echo "  open ${TRACE_FILE}"
echo ""
echo "Available profiling templates:"
echo "  Time Profiler    - CPU profiling (default)"
echo "  Allocations      - Memory allocation tracking"
echo "  Leaks            - Memory leak detection"
echo "  System Trace     - System-level performance"
echo ""
echo "To use a different template:"
echo "  ./profile-macos.sh 'Allocations'"
echo ""
echo "To list all available templates:"
echo "  xctrace list templates"
