#!/usr/bin/env bash
# Release build script for Godot Sandbox
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Building Godot Sandbox (Release)"

# Check if submodules are initialized
if [[ ! -f "ext/godot-cpp/CMakeLists.txt" ]]; then
    print_status "Initializing git submodules..."
    git submodule update --init --recursive
fi

# Create build directory
mkdir -p .build
pushd .build

# Configure with CMake
print_status "Configuring with CMake..."
if cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release; then
    print_success "CMake configuration completed"
else
    print_error "CMake configuration failed"
    exit 1
fi

# Build with Ninja
print_status "Building with Ninja..."
if ninja; then
    print_success "Build completed successfully"
else
    print_error "Build failed"
    exit 1
fi

popd

print_success "🎉 Release build complete!"
print_status "Output library: .build/libgodot-riscv.so"
