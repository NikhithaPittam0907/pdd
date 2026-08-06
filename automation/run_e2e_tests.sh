#!/usr/bin/env bash
set -e

echo "=== Android Emulator Boot Verification ==="
echo "Waiting for ADB device..."
adb wait-for-device

until adb shell getprop sys.boot_completed | grep -m 1 "1"; do
  echo "Still booting..."
  sleep 5
done

echo "✔ Emulator booted successfully."
adb devices
echo "Android Release Version:"
adb shell getprop ro.build.version.release

echo "=== Disabling Android Window Animations ==="
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0

echo "=== Installing Flutter APK on Emulator ==="
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
if [ ! -f "$APK_PATH" ]; then
  echo "ERROR: Flutter APK not found at $APK_PATH"
  exit 1
fi

adb install -r "$APK_PATH"
echo "✔ APK installed successfully."

echo "=== Initializing Appium Server & Executing Tests ==="
cd automation

node generate_tests.js || true
npx appium driver install uiautomator2 || true
npx appium > logs/appium.log 2>&1 &

echo "Waiting for Appium server to start..."
sleep 15

npm run wdio || true
echo "=== E2E Script Execution Completed ==="
