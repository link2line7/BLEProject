# BLEMiddleware Project

## Overview

The BLEMiddleware project provides a comprehensive middleware solution for managing Bluetooth Low Energy (BLE) connections in iOS applications. It includes functionality for discovering, connecting to, and disconnecting from BLE peripherals, with built-in device name stability and comprehensive error handling.

## Features

- **BLE Discovery**: Automatically discover nearby BLE peripherals with filtering capabilities
- **Connection Management**: Robust connect/disconnect functionality with automatic retry mechanisms
- **Device Name Stability**: Prevents device name changes after connection by caching advertised names
- **Error Handling**: Comprehensive error handling for all BLE operations
- **Comprehensive Documentation**: Full DocC documentation with examples and best practices

## Project Structure

```
BLEMiddleware
├── BLEProject.xcodeproj          # Xcode project file
├── BLEApp/                       # Demo application
│   ├── ViewController.swift      # Main view controller with BLE functionality
│   ├── BLETableViewCell.swift    # Custom table view cell for device display
│   ├── Main.storyboard           # UI layout
│   ├── AppDelegate.swift         # Application delegate
│   ├── SceneDelegate.swift       # Scene management
│   └── Assets.xcassets          # Image and color assets
├── BLEMiddleware/                # Middleware framework
│   ├── BLEMiddleware.swift       # Main middleware class
│   ├── BLEPeripheral.swift       # BLE peripheral wrapper
│   └── Documentation.docc/      # DocC documentation
│       ├── BLEMiddleware.md      # Main documentation
│       ├── GettingStarted.md     # Getting started guide
│       ├── ErrorHandling.md      # Error handling guide
│       └── DeviceNameStability.md # Device name stability guide
├── BLEMiddlewareTests/           # Unit tests
│   └── BLEMiddlewareTests.swift  # Comprehensive test suite
├── COMPATIBILITY.md              # Xcode version compatibility guide
└── README.md                     # This file
```

## Quick Start

### 1. Basic Setup

```swift
import BLEMiddleware

class ViewController: UIViewController {
    private let bleMiddleware = BLEMiddleware()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bleMiddleware.delegate = self
    }
}
```

### 2. Implement Delegate Methods

```swift
extension ViewController: BLEMiddlewareDelegate {
    func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState) {
        if state == .poweredOn {
            middleware.discoverPeripherals()
        }
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
        print("Discovered: \(peripheral.displayName)")
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didConnectPeripheral peripheral: BLEPeripheral) {
        print("Connected to: \(peripheral.displayName)")
    }
}
```

### 3. Display Devices

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let peripheral = bleMiddleware.discoveredPeripherals[indexPath.row]
    
    // Use displayName for stable device names
    cell.nameLabel.text = peripheral.displayName
    cell.idLabel.text = peripheral.identifier.uuidString
    
    return cell
}
```

## Key Features

### Device Name Stability

BLEMiddleware automatically handles device name changes that can occur after connection:

```swift
// Names remain consistent before and after connection
let stableName = peripheral.displayName  // Always shows the advertised name
```

### Robust Connection Management

```swift
// Connect to a device
bleMiddleware.connectToPeripheral(peripheral)

// Disconnect from a device
bleMiddleware.disconnectFromPeripheral(peripheral)

// Check connection status
if peripheral.isConnected {
    // Device is connected
}
```

### Comprehensive Error Handling

All errors are reported through delegate methods with detailed information:

```swift
func bleMiddleware(_ middleware: BLEMiddleware, didDisconnectPeripheral peripheral: BLEPeripheral, error: Error?) {
    if let error = error {
        // Handle unexpected disconnection
        print("Connection lost: \(error.localizedDescription)")
    }
}
```

## Requirements

- **iOS**: 15.0+
- **Xcode**: 14.0+ (see COMPATIBILITY.md for other versions)
- **Swift**: 5.0+
- **Frameworks**: CoreBluetooth, Foundation

## Installation

### Manual Integration

1. Clone or download the project
2. Drag the `BLEMiddleware` folder into your Xcode project
3. Ensure the framework is added to your target
4. Import the framework: `import BLEMiddleware`

### Permissions

Add Bluetooth usage description to your `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to nearby devices.</string>
```

## Documentation

Comprehensive documentation is available in the `Documentation.docc` folder:

- **Getting Started**: Step-by-step integration guide
- **API Reference**: Complete API documentation with examples
- **Error Handling**: Comprehensive error handling strategies
- **Device Name Stability**: Understanding and preventing name changes
- **Best Practices**: Performance and battery optimization tips

## Testing

The project includes a comprehensive test suite covering:

- Middleware initialization and configuration
- Device discovery and connection management
- Delegate method callbacks
- Error handling scenarios
- Performance testing

Run tests using: `Cmd + U` in Xcode

## Compatibility

- **Xcode 14.0 - 15.x**: Fully supported
- **Xcode 13.x**: Requires minor adjustments (see COMPATIBILITY.md)
- **Xcode 12.x and earlier**: Requires significant modifications

## Demo Application

The included demo app (`BLEApp`) showcases:

- Device discovery and display
- Connection/disconnection functionality
- Real-time status updates
- Stable device name display
- Manufacturer data parsing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add comprehensive tests for new functionality
4. Update documentation as needed
5. Submit a pull request

## License

This project is licensed under the MIT License. See the LICENSE file for more information.

## Support

For questions, issues, or feature requests:

1. Check the comprehensive documentation in `Documentation.docc`
2. Review the compatibility guide in `COMPATIBILITY.md`
3. Examine the demo application for implementation examples
4. Run the test suite to verify functionality