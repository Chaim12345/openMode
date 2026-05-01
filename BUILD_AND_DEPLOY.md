# OpenMode Build & Deployment Guide

## ✅ CI/CD Status

The OpenMode project now has full CI/CD automation via GitHub Actions!

### Automated Workflows

**On Every Push/PR:**
- ✅ Flutter SDK 3.24.0 setup
- ✅ Dependency installation
- ✅ Static analysis (flutter analyze)
- ✅ Unit tests, widget tests, integration tests
- ✅ Coverage reporting
- ✅ Web build (build/web/)
- ✅ Android APK build (build/app/outputs/flutter-apk/app-release.apk)

**On Master Branch:**
- ✅ Automatic deployment to GitHub Pages

## 🚀 Build Instructions

### Local Build Script

```bash
# Run the build script
./build_and_test.sh
```

### Manual Build Commands

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Run tests
flutter test

# Build for Web
flutter build web --release

# Build for Android
flutter build apk --release

# Build for iOS (macOS only)
flutter build ios --release
```

## 📦 Deployment

### Web Deployment

**Automated (via GitHub Actions):**
- Push to master → automatic deployment to GitHub Pages
- Access at: `https://Chaim12345.github.io/openMode/`

**Manual:**
```bash
flutter build web --release
# Deploy build/web/ to your web server
```

### Android Deployment

**Automated:**
- APK artifact available in GitHub Actions
- Download from: Actions → Workflow Run → Artifacts

**Manual:**
```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### iOS Deployment

```bash
flutter build ios --release
# Follow Xcode distribution steps
```

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
```

### Test Categories

**Unit Tests:**
- `test/domain/entities/` - Entity tests (Session, Message, etc.)
- `test/presentation/providers/` - Provider tests

**Widget Tests:**
- `test/presentation/widgets/` - UI component tests
- `test/ui_tests/` - End-to-end UI flow tests

**Integration Tests:**
- `test/integration/` - Full app flow tests

## 📊 Build Artifacts

After successful CI/CD run:

1. **Web Build**: `build/web/` (deployable static files)
2. **Android APK**: `build/app/outputs/flutter-apk/app-release.apk`
3. **Coverage Report**: `coverage/lcov.info`

## 🔧 Troubleshooting

### Build Fails

**Issue**: SDK version mismatch
```bash
flutter upgrade
flutter pub get
```

**Issue**: Dependency conflicts
```bash
flutter clean
flutter pub get
```

### Test Failures

**Issue**: Test dependencies missing
```bash
flutter pub get
flutter test
```

### Deployment Issues

**Web**: Ensure GitHub Pages is enabled in repository settings
**Android**: Check signing configuration for release builds
**iOS**: Requires macOS and Xcode

## 📈 CI/CD Workflow Status

Check current and past builds:
- GitHub → Actions → Flutter CI/CD

## 🎯 Next Steps

1. ✅ Enable GitHub Pages in repository settings
2. ✅ Configure deployment environment
3. ✅ Set up Codecov for coverage tracking
4. ✅ Add deployment notifications

---

*Last updated: 2026-05-01*
*Flutter Version: 3.24.0*
*Dart Version: 3.8.1+*
