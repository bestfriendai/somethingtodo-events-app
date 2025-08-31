#!/bin/bash

# SomethingToDo App Launch Script
# This script helps you easily run the Flutter app with Firebase

echo "🚀 SomethingToDo - Event Discovery App"
echo "================================"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run with error handling
run_command() {
    echo "⏳ $1..."
    if $2; then
        echo "✅ $1 completed"
    else
        echo "❌ $1 failed"
        exit 1
    fi
}

# Check dependencies
echo "🔍 Checking dependencies..."

if ! command_exists flutter; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

if ! command_exists firebase; then
    echo "❌ Firebase CLI not found. Please install Firebase CLI first."
    exit 1
fi

echo "✅ All dependencies found"

# Parse command line arguments
COMMAND=${1:-help}

case $COMMAND in
    setup)
        echo "📦 Setting up project..."
        run_command "Installing dependencies" "flutter pub get"
        run_command "Generating code" "flutter packages pub run build_runner build --delete-conflicting-outputs"
        echo "✅ Setup complete!"
        ;;
    
    ios)
        echo "📱 Running on iOS..."
        flutter run -d iphone
        ;;
    
    android)
        echo "🤖 Running on Android..."
        flutter run -d android
        ;;
    
    web)
        echo "🌐 Running on Web..."
        flutter run -d chrome --web-renderer html
        ;;
    
    build-ios)
        echo "📱 Building for iOS..."
        flutter build ios --release
        echo "✅ iOS build complete! Check build/ios/iphoneos/"
        ;;
    
    build-android)
        echo "🤖 Building for Android..."
        flutter build apk --release
        echo "✅ Android build complete! Check build/app/outputs/flutter-apk/"
        ;;
    
    build-web)
        echo "🌐 Building for Web..."
        flutter build web --release
        echo "✅ Web build complete! Check build/web/"
        ;;
    
    clean)
        echo "🧹 Cleaning project..."
        flutter clean
        rm -rf .dart_tool/
        rm -rf build/
        echo "✅ Clean complete!"
        ;;
    
    firebase-deploy)
        echo "🔥 Deploying to Firebase..."
        firebase deploy
        ;;
    
    firebase-emulator)
        echo "🔥 Starting Firebase Emulator..."
        firebase emulators:start
        ;;
    
    test)
        echo "🧪 Running tests..."
        flutter test
        ;;
    
    analyze)
        echo "🔍 Analyzing code..."
        flutter analyze
        ;;
    
    format)
        echo "✨ Formatting code..."
        dart format lib/
        ;;
    
    doctor)
        echo "🏥 Running Flutter Doctor..."
        flutter doctor -v
        ;;
    
    help|*)
        echo ""
        echo "Available commands:"
        echo "  ./launch.sh setup          - Install dependencies and generate code"
        echo "  ./launch.sh ios           - Run on iOS simulator/device"
        echo "  ./launch.sh android       - Run on Android emulator/device"
        echo "  ./launch.sh web           - Run on web browser"
        echo "  ./launch.sh build-ios     - Build iOS release"
        echo "  ./launch.sh build-android - Build Android APK"
        echo "  ./launch.sh build-web     - Build for web deployment"
        echo "  ./launch.sh clean         - Clean build files"
        echo "  ./launch.sh firebase-deploy - Deploy to Firebase"
        echo "  ./launch.sh firebase-emulator - Start Firebase emulator"
        echo "  ./launch.sh test          - Run tests"
        echo "  ./launch.sh analyze       - Analyze code"
        echo "  ./launch.sh format        - Format code"
        echo "  ./launch.sh doctor        - Check Flutter setup"
        echo "  ./launch.sh help          - Show this help"
        echo ""
        echo "Quick start:"
        echo "  1. ./launch.sh setup"
        echo "  2. ./launch.sh ios (or android/web)"
        echo ""
        ;;
esac