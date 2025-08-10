#!/bin/bash

echo "Testing Android build configuration..."
echo "Flutter version:"
flutter --version

echo ""
echo "Checking Flutter SDK path..."
if [ -f "android/local.properties" ]; then
    cat android/local.properties
else
    echo "local.properties not found, creating..."
    flutter config --android-sdk
fi

echo ""
echo "Checking Gradle wrapper..."
if [ -f "android/gradlew" ]; then
    cd android
    ./gradlew --version
    cd ..
else
    echo "Gradle wrapper not found"
fi

echo ""
echo "Attempting flutter build..."
flutter build apk --debug --verbose
