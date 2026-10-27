#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/.." && pwd)"
BUILD_DIR="$DIR/build"

echo "==> Building native CoreAudio & FLAC/WAV engine (Apple Silicon arm64)..."
mkdir -p "$BUILD_DIR"
clang++ -dynamiclib -std=c++17 -O2 \
    -install_name @rpath/libtsrossa-mac.dylib \
    -I "$ROOT_DIR/app/src/main/cpp" \
    -I "$DIR/src/nativeMain/cpp" \
    -framework CoreAudio -framework AudioToolbox -framework CoreFoundation \
    "$DIR/src/nativeMain/cpp/dr_impl.c" \
    "$DIR/src/nativeMain/cpp/CoreAudioSink.cpp" \
    "$DIR/src/nativeMain/cpp/TsrossaAudioBridge.cpp" \
    -o "$BUILD_DIR/libtsrossa-mac.dylib"

echo "==> Compiling tsrossa macOS application..."
mkdir -p "$BUILD_DIR/ModuleCache"
swiftc -parse-as-library \
    -module-cache-path "$BUILD_DIR/ModuleCache" \
    -import-objc-header "$DIR/src/nativeMain/cpp/TsrossaAudioBridge.h" \
    -L "$BUILD_DIR" -ltsrossa-mac \
    -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
    -Xlinker -rpath -Xlinker @loader_path \
    "$DIR/macos/Sources"/*.swift \
    -o "$BUILD_DIR/tsrossa"

echo "==> Bundling tsrossa.app..."
rm -rf "$BUILD_DIR/tsrossa.app"
mkdir -p "$BUILD_DIR/tsrossa.app/Contents/MacOS"
mkdir -p "$BUILD_DIR/tsrossa.app/Contents/Frameworks"
mkdir -p "$BUILD_DIR/tsrossa.app/Contents/Resources"

cp "$BUILD_DIR/tsrossa" "$BUILD_DIR/tsrossa.app/Contents/MacOS/"
cp "$BUILD_DIR/libtsrossa-mac.dylib" "$BUILD_DIR/tsrossa.app/Contents/Frameworks/"
cp "$DIR/macos/Info.plist" "$BUILD_DIR/tsrossa.app/Contents/"

codesign --force --deep -s - "$BUILD_DIR/tsrossa.app"

echo "==> Packaging tsrossa-1.6.0-macos.zip..."
(cd "$BUILD_DIR" && rm -f tsrossa-1.6.0-macos.zip && zip -r -y tsrossa-1.6.0-macos.zip tsrossa.app)

echo "==> Build complete! Output located at:"
echo "    App: $BUILD_DIR/tsrossa.app"
echo "    Zip: $BUILD_DIR/tsrossa-1.6.0-macos.zip"
