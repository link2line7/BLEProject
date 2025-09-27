# BLE Project Xcode Compatibility Guide

## Supported Xcode Versions

### ✅ Fully Compatible
- **Xcode 14.0 - 15.x**: No modifications needed, runs directly
- **Xcode 16.0+**: Should run normally

### ⚠️ Requires Adjustments

#### Xcode 13.x
The following adjustments are needed:

1. **Lower Deployment Target**
   ```
   iOS Deployment Target: 13.0 (change from 15.0 to 13.0)
   ```

2. **Remove New Version Features**
   Set in Build Settings:
   ```
   ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = NO
   ENABLE_USER_SCRIPT_SANDBOXING = NO
   ```

#### Xcode 12.x and Earlier
Major adjustments required:

1. **Lower Deployment Target**
   ```
   iOS Deployment Target: 12.0
   ```

2. **Adjust Project Format**
   ```
   Project Format: Xcode 12.0-compatible
   ```

3. **Remove DocC Documentation**
   - Delete `.docc` folder
   - Or remove it from Build Phases

## Quick Compatibility Check

### Check Current Configuration
```bash
# View Xcode version
xcodebuild -version

# View project settings
xcodebuild -project BLEProject.xcodeproj -showBuildSettings
```

### Modify Deployment Target
1. Open project settings
2. Select Project → Build Settings
3. Search for "iOS Deployment Target"
4. Change to iOS version supported by target Xcode version

## Code Compatibility

### Swift Syntax
- Uses Swift 5.0 syntax, good compatibility
- Avoid using latest Swift features

### iOS API
- Currently supports minimum iOS 15.0
- To support earlier versions, add availability checks:

```swift
if #available(iOS 15.0, *) {
    // iOS 15+ features
} else {
    // Fallback handling
}
```

### Core Bluetooth
- Core Bluetooth API is stable on iOS 13+
- Main APIs are backward compatible

## Testing Recommendations

### Test on Different Xcode Versions
1. **Xcode 14**: Main development version
2. **Xcode 13**: Compatibility testing
3. **Xcode 15+**: New version testing

### Device Testing
- iOS 13.0+ devices
- Different iPhone/iPad models
- Simulator testing

## Release Considerations

### App Store Compatibility
- Compile with latest Xcode version
- Support latest iOS version
- Backward compatible with at least 2-3 iOS versions

### Enterprise Distribution
- Can use older Xcode versions
- Ensure target device support

## Troubleshooting

### Common Issues
1. **Compilation Errors**: Check Swift version and deployment target
2. **API Unavailable**: Add availability checks
3. **Project Format**: Downgrade project format version

### Solutions
1. Clean project: `Product → Clean Build Folder`
2. Reset simulator: `Device → Erase All Content and Settings`
3. Update certificates and provisioning profiles