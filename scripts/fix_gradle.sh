#!/bin/bash

echo "🔧 Fixing Gradle and dependency issues..."

# Clean everything first
flutter clean

# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version=8.3 --distribution-type=all
cd ..

# Get dependencies with version solving
flutter pub get

# Check for dependency conflicts
echo "📋 Checking for dependency conflicts..."
flutter pub deps

echo "✅ Gradle fixes applied!"
echo ""
echo "Next steps:"
echo "1. Run 'flutter pub outdated' to see available updates"
echo "2. Run 'flutter doctor' to check for other issues"
echo "3. Test with 'flutter run'"
