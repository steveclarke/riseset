app_name := "RiseSet"
app_bundle := app_name + ".app"

# List available recipes
default:
    @just --list

# Build the Swift package
build:
    swift build

# Build and create .app bundle
bundle: build
    rm -rf "{{app_bundle}}"
    mkdir -p "{{app_bundle}}/Contents/MacOS"
    mkdir -p "{{app_bundle}}/Contents/Resources"
    cp ".build/debug/{{app_name}}" "{{app_bundle}}/Contents/MacOS/"
    cp "RiseSet/Info.plist" "{{app_bundle}}/Contents/"
    cp "RiseSet/Assets.xcassets/AppIcon.appiconset/icon_1024.png" "{{app_bundle}}/Contents/Resources/AppIcon.png"
    echo -n "APPL????" > "{{app_bundle}}/Contents/PkgInfo"
    codesign --force --deep --sign - "{{app_bundle}}"
    @echo "Created {{app_bundle}}"

# Build, bundle, and run
run: bundle
    open "{{app_bundle}}"

# Build, bundle, and install to /Applications
install: bundle
    rm -rf "/Applications/{{app_bundle}}"
    cp -r "{{app_bundle}}" "/Applications/"
    @echo "Installed to /Applications/{{app_bundle}}"

# Clean build artifacts
clean:
    rm -rf .build
    rm -rf "{{app_bundle}}"
