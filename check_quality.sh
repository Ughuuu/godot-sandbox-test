#!/usr/bin/env bash

# Code Quality Check Script for Godot Sandbox
# Runs various code quality checks to ensure consistent standards

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🔍 $1${NC}"
    echo "----------------------------------------"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the right directory
if [[ ! -f "CMakeLists.txt" ]] || [[ ! -d "src" ]]; then
    print_error "Please run this script from the root of the godot-sandbox repository"
    exit 1
fi

total_issues=0

# Check 1: Code Formatting
print_header "Code Formatting Check"
if command -v clang-format >/dev/null 2>&1; then
    # Save current state
    git stash push -m "quality-check-stash" --quiet || true
    
    # Run clang-format
    if ./scripts/clang-format.sh; then
        print_success "Code formatting is correct"
    else
        print_error "Code formatting issues found"
        echo "Run: ./scripts/clang-format.sh to see details"
        ((total_issues++))
    fi
    
    # Restore state
    git stash pop --quiet 2>/dev/null || true
else
    print_warning "clang-format not found, skipping format check"
fi

# Check 2: Build Test
print_header "Build Test"
if [[ -d ".build" ]]; then
    rm -rf .build
fi

if ./build.sh >/dev/null 2>&1; then
    print_success "Project builds successfully"
else
    print_error "Build failed"
    echo "Run: ./build.sh to see details"
    ((total_issues++))
fi

# Check 3: File Line Endings
print_header "Line Ending Check"
files_with_crlf=()
while IFS= read -r -d '' file; do
    if [[ -f "$file" ]] && file "$file" | grep -q "CRLF"; then
        files_with_crlf+=("$file")
    fi
done < <(find src program -name "*.cpp" -o -name "*.h" -print0 2>/dev/null)

if [[ ${#files_with_crlf[@]} -eq 0 ]]; then
    print_success "All source files have correct line endings"
else
    print_error "Files with CRLF line endings found:"
    for file in "${files_with_crlf[@]}"; do
        echo "  $file"
    done
    echo "Fix with: dos2unix <file>"
    ((total_issues++))
fi

# Check 4: TODO/FIXME Comments
print_header "Code Cleanup Check"
todos=$(find src program -name "*.cpp" -o -name "*.h" | xargs grep -n "TODO\|FIXME\|XXX\|HACK" 2>/dev/null | wc -l)
if [[ $todos -gt 0 ]]; then
    print_warning "Found $todos TODO/FIXME/XXX/HACK comments"
    find src program -name "*.cpp" -o -name "*.h" | xargs grep -n "TODO\|FIXME\|XXX\|HACK" 2>/dev/null | head -10
    if [[ $todos -gt 10 ]]; then
        echo "... and $(($todos - 10)) more"
    fi
else
    print_success "No TODO/FIXME comments found"
fi

# Check 5: Large Files
print_header "File Size Check"
large_files=()
while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        lines=$(wc -l < "$file")
        if [[ $lines -gt 1000 ]]; then
            large_files+=("$file:$lines")
        fi
    fi
done < <(find src -name "*.cpp" -o -name "*.h" -print0 2>/dev/null)

if [[ ${#large_files[@]} -eq 0 ]]; then
    print_success "No overly large source files found"
else
    print_warning "Large source files found (>1000 lines):"
    for file_info in "${large_files[@]}"; do
        echo "  $file_info lines"
    done
    echo "Consider splitting large files into smaller, focused modules"
fi

# Check 6: Unused Includes (basic check)
print_header "Include Check"
if command -v include-what-you-use >/dev/null 2>&1; then
    print_success "include-what-you-use found (advanced checks available)"
else
    print_warning "include-what-you-use not found, skipping advanced include checks"
fi

# Check 7: Git Status
print_header "Git Status Check"
if [[ -n $(git status --porcelain) ]]; then
    print_warning "Working directory has uncommitted changes"
    git status --short
else
    print_success "Working directory is clean"
fi

# Summary
echo ""
echo "========================================"
if [[ $total_issues -eq 0 ]]; then
    print_success "🎉 All quality checks passed!"
    echo "Your code meets the quality standards."
else
    print_error "⚠️  Found $total_issues critical issue(s)"
    echo "Please address the issues above before submitting."
    exit 1
fi