#!/usr/bin/env bash

# Development Environment Setup Script for Godot Sandbox
# This script helps new contributors set up their development environment

set -e

echo "🚀 Setting up Godot Sandbox development environment..."

# Color definitions for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "CMakeLists.txt" ]] || [[ ! -d "src" ]]; then
    print_error "Please run this script from the root of the godot-sandbox repository"
    exit 1
fi

# Initialize submodules
print_status "Initializing git submodules..."
if git submodule update --init --recursive; then
    print_success "Git submodules initialized successfully"
else
    print_error "Failed to initialize git submodules"
    exit 1
fi

# Check for required tools
print_status "Checking for required development tools..."

check_tool() {
    if command -v "$1" >/dev/null 2>&1; then
        print_success "$1 is available"
        return 0
    else
        print_warning "$1 is not available"
        return 1
    fi
}

# Essential tools
missing_tools=()
check_tool "cmake" || missing_tools+=("cmake")
check_tool "ninja" || missing_tools+=("ninja-build")
check_tool "gcc" || missing_tools+=("build-essential")
check_tool "g++" || missing_tools+=("build-essential")

# Optional but recommended tools
check_tool "clang-format" || print_warning "clang-format not found - code formatting will not work"
check_tool "python3" || missing_tools+=("python3")
check_tool "scons" || print_warning "SCons not found - alternative build system will not work"

# Cross-compilation toolchain
check_tool "riscv64-linux-gnu-gcc" || print_warning "RISC-V cross-compiler not found - tests may not work"

if [[ ${#missing_tools[@]} -gt 0 ]]; then
    print_warning "Missing required tools. On Ubuntu/Debian, install with:"
    echo "sudo apt update && sudo apt install ${missing_tools[*]}"
    
    print_warning "For RISC-V cross-compilation (needed for tests):"
    echo "sudo apt install gcc-riscv64-linux-gnu g++-riscv64-linux-gnu"
    
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create build directory and configure
print_status "Configuring build environment..."
mkdir -p .build
cd .build

if cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug; then
    print_success "CMake configuration completed"
else
    print_error "CMake configuration failed"
    exit 1
fi

cd ..

# Build the project
print_status "Building the project..."
if cmake --build .build --parallel $(nproc); then
    print_success "Build completed successfully"
else
    print_error "Build failed"
    exit 1
fi

# Set up IDE configurations
print_status "Setting up IDE configurations..."

# VS Code settings
if [[ ! -d ".vscode" ]]; then
    mkdir -p .vscode
    cat > .vscode/settings.json << 'EOF'
{
    "C_Cpp.default.configurationProvider": "ms-vscode.cmake-tools",
    "C_Cpp.default.intelliSenseMode": "gcc-x64",
    "files.associations": {
        "*.h": "cpp",
        "*.hpp": "cpp"
    },
    "editor.insertSpaces": false,
    "editor.tabSize": 4,
    "C_Cpp.clang_format_style": "file"
}
EOF
    print_success "VS Code configuration created"
fi

# Create useful development scripts
print_status "Creating development helper scripts..."

cat > dev_build.sh << 'EOF'
#!/usr/bin/env bash
# Quick development build script
set -e
echo "🔨 Building Godot Sandbox (Debug)..."
cmake --build .build --parallel $(nproc)
echo "✅ Build complete!"
EOF
chmod +x dev_build.sh

cat > dev_test.sh << 'EOF'
#!/usr/bin/env bash
# Quick test runner script
set -e
cd tests
if [[ ! -f "./Godot_v4.4.1-stable_linux.x86_64" ]]; then
    echo "📥 Downloading Godot for tests..."
    wget -q https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip
    unzip -q Godot_v4.4.1-stable_linux.x86_64.zip
    rm Godot_v4.4.1-stable_linux.x86_64.zip
fi
echo "🧪 Running tests..."
GODOT=./Godot_v4.4.1-stable_linux.x86_64 ./run_unittests.sh
EOF
chmod +x dev_test.sh

print_success "Development helper scripts created"

print_status "Running code format check..."
if ./scripts/clang-format.sh; then
    print_success "Code format check passed"
else
    print_warning "Code format issues found - please run clang-format"
fi

echo ""
print_success "🎉 Development environment setup complete!"
echo ""
echo "📚 Quick development commands:"
echo "  ./dev_build.sh     - Quick build"
echo "  ./dev_test.sh      - Run tests"
echo "  ./build.sh         - Full release build"
echo ""
echo "📖 Next steps:"
echo "  1. Open the project in your preferred IDE"
echo "  2. Check the README.md for usage instructions"
echo "  3. Look at the 'program' directory for example code"
echo "  4. Run tests to verify everything works"
echo ""
print_success "Happy coding! 🚀"