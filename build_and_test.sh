#!/bin/bash

# OpenMode Build and Test Script
# This script builds the app for web and mobile, then runs tests

set -e

echo "========================================="
echo "OpenMode Build & Test Script"
echo "========================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "   Visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version)"

# Clean build
echo ""
echo "🧹 Cleaning build artifacts..."
flutter clean

# Get dependencies
echo ""
echo "📦 Getting dependencies..."
flutter pub get

# Run analyzer
echo ""
echo "🔍 Running Flutter Analyzer..."
flutter analyze

# Run tests
echo ""
echo "🧪 Running tests..."
flutter test

# Build for Web
echo ""
echo "🌐 Building for Web..."
flutter build web --release
echo "✅ Web build complete: build/web/"

# Build for Android (if Android SDK available)
echo ""
echo "📱 Building for Android..."
if flutter devices | grep -q "android"; then
    flutter build apk --release
    echo "✅ Android APK build complete: build/app/outputs/flutter-apk/"
else
    echo "⚠️  No Android device/emulator found. Skipping Android build."
    echo "   APK can be built later with: flutter build apk --release"
fi

# Build for iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo "🍎 Building for iOS..."
    if flutter devices | grep -q "iphone"; then
        flutter build ios --release
        echo "✅ iOS build complete: build/ios/iphoneos/"
    else
        echo "⚠️  No iOS device/simulator found. Skipping iOS build."
    fi
fi

# Summary
echo ""
echo "========================================="
echo "✅ Build & Test Summary"
echo "========================================="
echo "Web Build:      build/web/"
echo "Android APK:    build/app/outputs/flutter-apk/app-release.apk"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "iOS Build:      build/ios/iphoneos/"
fi
echo "Test Results:   See above"
echo "========================================="
echo ""
echo "🎉 Build complete! You can now:"
echo "   - Deploy web: Serve build/web/ directory"
echo "   - Install Android: Install build/app/outputs/flutter-apk/app-release.apk"
echo "   - Deploy iOS: Follow Xcode deployment instructions"

