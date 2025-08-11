#!/usr/bin/env bash

# Performance monitoring script for build times
# Helps track build performance improvements over time

set -e

BUILD_TYPE=${1:-Debug}
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
PERF_LOG="build_performance.log"

echo "🏃 Performance Build Test - $BUILD_TYPE"
echo "Timestamp: $(date)"

# Clean build directory
if [[ -d ".build" ]]; then
    rm -rf .build
    echo "Cleaned build directory"
fi

# Time the build process
echo "Starting build..."
start_time=$(date +%s)

if [[ "$BUILD_TYPE" == "Release" ]]; then
    if ./build.sh >/dev/null 2>&1; then
        build_success=true
    else
        build_success=false
    fi
else
    # Debug build
    mkdir -p .build
    cd .build
    if cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug >/dev/null 2>&1 && ninja >/dev/null 2>&1; then
        build_success=true
    else
        build_success=false
    fi
    cd ..
fi

end_time=$(date +%s)
duration=$((end_time - start_time))

# Log results
if [[ "$build_success" == true ]]; then
    echo "✅ Build completed successfully in ${duration}s"
    echo "$TIMESTAMP,$BUILD_TYPE,SUCCESS,$duration" >> "$PERF_LOG"
else
    echo "❌ Build failed after ${duration}s"
    echo "$TIMESTAMP,$BUILD_TYPE,FAILED,$duration" >> "$PERF_LOG"
    exit 1
fi

# Show performance history if log exists and has entries
if [[ -f "$PERF_LOG" ]] && [[ $(wc -l < "$PERF_LOG") -gt 1 ]]; then
    echo ""
    echo "📊 Recent Build Performance (last 5 builds):"
    echo "Date,Type,Status,Time(s)"
    tail -5 "$PERF_LOG" | while IFS=',' read -r timestamp type status time; do
        if [[ "$status" == "SUCCESS" ]]; then
            echo "  $timestamp $type ✅ ${time}s"
        else
            echo "  $timestamp $type ❌ ${time}s"
        fi
    done
fi