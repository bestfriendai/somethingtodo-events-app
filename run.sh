#!/bin/bash

# SomethingToDo Development Script
# Usage: ./run.sh [command]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Flutter installation
check_flutter() {
    if ! command_exists flutter; then
        print_error "Flutter is not installed. Please install Flutter first."
        exit 1
    fi
    
    print_status "Flutter version:"
    flutter --version
}

# Install dependencies
install_deps() {
    print_status "Installing Flutter dependencies..."
    flutter pub get
    
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
}

# Generate model files
generate_models() {
    print_status "Generating model files..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    if [ $? -eq 0 ]; then
        print_success "Model files generated successfully"
    else
        print_error "Failed to generate model files"
        exit 1
    fi
}

# Clean build files
clean() {
    print_status "Cleaning build files..."
    flutter clean
    rm -rf .dart_tool/build
    
    print_success "Build files cleaned"
}

# Run the app in debug mode
run_debug() {
    print_status "Running app in debug mode..."
    flutter run --debug
}

# Run the app in release mode
run_release() {
    print_status "Running app in release mode..."
    flutter run --release
}

# Build APK
build_apk() {
    print_status "Building APK..."
    flutter build apk --release
    
    if [ $? -eq 0 ]; then
        print_success "APK built successfully"
        echo "Location: build/app/outputs/flutter-apk/app-release.apk"
    else
        print_error "Failed to build APK"
        exit 1
    fi
}

# Build App Bundle
build_appbundle() {
    print_status "Building App Bundle..."
    flutter build appbundle --release
    
    if [ $? -eq 0 ]; then
        print_success "App Bundle built successfully"
        echo "Location: build/app/outputs/bundle/release/app-release.aab"
    else
        print_error "Failed to build App Bundle"
        exit 1
    fi
}

# Build iOS
build_ios() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "iOS builds are only supported on macOS"
        exit 1
    fi
    
    print_status "Building iOS app..."
    flutter build ios --release
    
    if [ $? -eq 0 ]; then
        print_success "iOS app built successfully"
    else
        print_error "Failed to build iOS app"
        exit 1
    fi
}

# Run tests
run_tests() {
    print_status "Running tests..."
    flutter test
    
    if [ $? -eq 0 ]; then
        print_success "All tests passed"
    else
        print_error "Some tests failed"
        exit 1
    fi
}

# Analyze code
analyze() {
    print_status "Analyzing code..."
    flutter analyze
    
    if [ $? -eq 0 ]; then
        print_success "No issues found"
    else
        print_warning "Please check the issues above"
    fi
}

# Format code
format() {
    print_status "Formatting code..."
    dart format .
    print_success "Code formatted"
}

# Setup Firebase (requires Firebase CLI)
setup_firebase() {
    if ! command_exists firebase; then
        print_error "Firebase CLI is not installed. Please install it first:"
        echo "npm install -g firebase-tools"
        exit 1
    fi
    
    print_status "Setting up Firebase..."
    firebase login
    firebase init
    
    print_success "Firebase setup complete"
}

# Deploy Cloud Functions
deploy_functions() {
    if ! command_exists firebase; then
        print_error "Firebase CLI is not installed"
        exit 1
    fi
    
    print_status "Deploying Cloud Functions..."
    cd functions
    npm install
    npm run build
    cd ..
    firebase deploy --only functions
    
    if [ $? -eq 0 ]; then
        print_success "Cloud Functions deployed successfully"
    else
        print_error "Failed to deploy Cloud Functions"
        exit 1
    fi
}

# Deploy Firestore rules
deploy_firestore() {
    if ! command_exists firebase; then
        print_error "Firebase CLI is not installed"
        exit 1
    fi
    
    print_status "Deploying Firestore rules and indexes..."
    firebase deploy --only firestore
    
    if [ $? -eq 0 ]; then
        print_success "Firestore rules and indexes deployed successfully"
    else
        print_error "Failed to deploy Firestore configuration"
        exit 1
    fi
}

# Full setup for new developers
setup() {
    print_status "Setting up SomethingToDo development environment..."
    
    check_flutter
    install_deps
    generate_models
    
    print_success "Setup complete! You can now run: ./run.sh debug"
}

# Show help
show_help() {
    echo -e "${BLUE}SomethingToDo Development Script${NC}"
    echo ""
    echo "Usage: ./run.sh [command]"
    echo ""
    echo "Commands:"
    echo "  setup           - Full setup for new developers"
    echo "  install         - Install Flutter dependencies"
    echo "  generate        - Generate model files"
    echo "  clean           - Clean build files"
    echo "  debug           - Run app in debug mode"
    echo "  release         - Run app in release mode"
    echo "  build-apk       - Build Android APK"
    echo "  build-bundle    - Build Android App Bundle"
    echo "  build-ios       - Build iOS app (macOS only)"
    echo "  test            - Run tests"
    echo "  analyze         - Analyze code"
    echo "  format          - Format code"
    echo "  firebase-setup  - Setup Firebase project"
    echo "  deploy-functions - Deploy Cloud Functions"
    echo "  deploy-firestore - Deploy Firestore rules"
    echo "  help            - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./run.sh setup"
    echo "  ./run.sh debug"
    echo "  ./run.sh build-apk"
}

# Main script logic
case "${1:-help}" in
    setup)
        setup
        ;;
    install)
        install_deps
        ;;
    generate)
        generate_models
        ;;
    clean)
        clean
        ;;
    debug)
        run_debug
        ;;
    release)
        run_release
        ;;
    build-apk)
        build_apk
        ;;
    build-bundle)
        build_appbundle
        ;;
    build-ios)
        build_ios
        ;;
    test)
        run_tests
        ;;
    analyze)
        analyze
        ;;
    format)
        format
        ;;
    firebase-setup)
        setup_firebase
        ;;
    deploy-functions)
        deploy_functions
        ;;
    deploy-firestore)
        deploy_firestore
        ;;
    help)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac