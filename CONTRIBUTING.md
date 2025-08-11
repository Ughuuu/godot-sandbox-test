# Contributing to Godot Sandbox

Thank you for your interest in contributing to Godot Sandbox! This guide will help you get started with development and understand our contribution process.

## 🚀 Quick Start

### Prerequisites

- **CMake** 3.16 or later
- **Ninja** build system (recommended)
- **C++ compiler** with C++20 support (GCC 11+ or Clang 12+)
- **Python 3.7+** for build scripts
- **Git** with submodule support

#### Platform-specific dependencies

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install cmake ninja-build build-essential python3 clang-format
# For cross-compilation and tests:
sudo apt install gcc-riscv64-linux-gnu g++-riscv64-linux-gnu
```

**Fedora:**
```bash
sudo dnf install cmake ninja-build gcc-c++ python3 clang-tools-extra
sudo dnf install gcc-riscv64-linux-gnu
```

**macOS:**
```bash
brew install cmake ninja llvm python3
```

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone --recursive https://github.com/libriscv/godot-sandbox.git
   cd godot-sandbox
   ```

2. **Run the development setup script:**
   ```bash
   ./setup_dev.sh
   ```

3. **Verify the setup:**
   ```bash
   ./dev_build.sh  # Quick build
   ./dev_test.sh   # Run tests (downloads Godot if needed)
   ```

## 🛠 Development Workflow

### Building the Project

**Debug build (recommended for development):**
```bash
./dev_build.sh
```

**Release build:**
```bash
./build.sh
```

**Manual CMake build:**
```bash
mkdir -p .build && cd .build
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug
ninja
```

### Code Style and Formatting

We use **clang-format** with the configuration in `.clang-format`. Please ensure your code follows our style:

```bash
# Check formatting
./scripts/clang-format.sh

# Auto-format all code
clang-format -i src/**/*.cpp src/**/*.h
```

**Key style guidelines:**
- Use tabs for indentation
- Brace style: Allman (braces on new lines)
- Line length: 120 characters max
- Function names: `snake_case`
- Class names: `PascalCase`
- Member variables: `m_variable_name`

### Testing

**Run unit tests:**
```bash
cd tests
GODOT=/path/to/godot ./run_unittests.sh
# or use the helper script:
./dev_test.sh
```

**Add new tests:**
- C++ tests: Add to `tests/tests/`
- Follow existing test patterns
- Ensure tests are deterministic and isolated

### Code Architecture

**Directory Structure:**
```
src/
├── cpp/           # C++ scripting language support
├── rust/          # Rust scripting language support  
├── zig/           # Zig scripting language support
├── elf/           # ELF binary handling
├── godot/         # Godot engine integration
├── bintr/         # Binary translator
└── tests/         # Test utilities
```

**Key Components:**
- `Sandbox`: Main sandboxed execution environment
- `Script*`: Language-specific script implementations
- `sandbox_syscalls.cpp`: System call implementations
- `sandbox_*.cpp`: Core sandbox functionality

## 📝 Contribution Guidelines

### Submitting Changes

1. **Fork** the repository on GitHub
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following our coding standards
4. **Test your changes** thoroughly
5. **Commit** with descriptive messages
6. **Push** to your fork and create a **Pull Request**

### Pull Request Process

1. **Ensure all tests pass** and code builds successfully
2. **Update documentation** if you're changing APIs
3. **Add tests** for new functionality
4. **Follow the PR template** and provide clear description
5. **Respond to review feedback** promptly

### Commit Message Format

Use clear, descriptive commit messages:

```
type(scope): brief description

Longer description if needed, explaining what and why,
not how. Wrap at 72 characters.

Fixes #issue-number
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### What to Contribute

**Good first issues:**
- 🐛 Bug fixes
- 📝 Documentation improvements  
- 🧪 Test coverage expansion
- 🎨 Code cleanup and refactoring
- 💡 Performance optimizations

**Areas needing help:**
- Cross-platform compatibility
- Security auditing
- Performance optimization
- Language binding improvements
- Example programs

## 🏗 Architecture Guidelines

### Adding New Features

1. **Design first**: Open an issue to discuss major changes
2. **Start small**: Implement MVP first
3. **Test thoroughly**: Add comprehensive tests
4. **Document**: Update API docs and examples

### Code Quality Standards

- **Safety first**: This is a security-focused project
- **Performance matters**: Profile critical paths
- **Clean interfaces**: Keep APIs simple and consistent  
- **Error handling**: Always handle error cases gracefully
- **Memory management**: Be explicit about ownership
- **Thread safety**: Document threading requirements

### Security Considerations

When working on sandbox functionality:

- **Validate all inputs** from guest programs
- **Enforce resource limits** strictly
- **Assume malicious intent** from guest code
- **Test with hostile inputs**
- **Document security implications** of changes

## 🐛 Reporting Issues

### Bug Reports

Please include:
- **Environment details** (OS, compiler, versions)
- **Reproduction steps** (minimal test case)
- **Expected vs actual behavior**
- **Error messages** and logs
- **Relevant code snippets**

### Feature Requests

Please include:
- **Use case description** 
- **Proposed solution** (if any)
- **Impact assessment**
- **Implementation complexity** estimate

## 📚 Resources

- [Project Documentation](README.md)
- [API Examples](https://github.com/libriscv/godot-sandbox-programs)
- [libriscv Documentation](https://libriscv.no)
- [Godot Engine Documentation](https://docs.godotengine.org/)
- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)

## 💬 Community

- **Discord**: [Join our Discord server](https://discord.gg/n4GcXr66X5)
- **Issues**: Use GitHub Issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE)).

---

Thank you for contributing to Godot Sandbox! Every contribution helps make secure sandboxing better for the entire Godot community. 🙏