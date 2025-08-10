#!/bin/bash

echo "📦 Updating dependencies safely..."

# Backup current pubspec.yaml
cp pubspec.yaml pubspec.yaml.backup

# Check what's outdated
echo "Checking outdated packages..."
flutter pub outdated

echo ""
echo "Would you like to update dependencies? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Update dependencies
    flutter pub upgrade --major-versions
    
    # Clean and get dependencies
    flutter clean
    flutter pub get
    
    # Try to build
    echo "Testing build..."
    if flutter build apk --debug; then
        echo "✅ Build successful with updated dependencies!"
    else
        echo "❌ Build failed. Restoring backup..."
        cp pubspec.yaml.backup pubspec.yaml
        flutter pub get
    fi
else
    echo "Skipping dependency updates."
fi

# Clean up backup
rm -f pubspec.yaml.backup
