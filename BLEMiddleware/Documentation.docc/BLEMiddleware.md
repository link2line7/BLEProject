# ``BLEMiddleware``

A comprehensive Bluetooth Low Energy middleware for iOS applications.

## Overview

BLEMiddleware provides a simplified, high-level interface for Bluetooth Low Energy operations in iOS applications. It abstracts the complexity of Core Bluetooth while providing essential functionality for device discovery, connection management, and peripheral interactions.

### Key Features

- **Simplified API**: Easy-to-use methods for common BLE operations
- **Automatic Management**: Handles Core Bluetooth lifecycle and state management
- **Delegate Pattern**: Clean callback system for asynchronous operations
- **Error Handling**: Comprehensive error reporting and recovery
- **Memory Management**: Automatic cleanup and resource management

## Getting Started

### Basic Setup

```swift
import BLEMiddleware

class ViewController: UIViewController {
    let middleware = BLEMiddleware()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        middleware.delegate = self
    }
}

extension ViewController: BLEMiddlewareDelegate {
    func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState) {
        if state == .poweredOn {
            middleware.discoverPeripherals()
        }
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
        print("Discovered: \(peripheral.name ?? "Unknown Device")")
        // Connect to the peripheral if desired
        middleware.connectToPeripheral(peripheral)
    }
}
```

### Permissions Setup

Add the following to your app's `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to nearby devices.</string>
```

## Architecture

### Core Components

- **BLEMiddleware**: Main class that manages all BLE operations
- **BLEPeripheral**: Represents a discovered or connected BLE device
- **BLEMiddlewareDelegate**: Protocol for receiving middleware events

### State Management

The middleware automatically manages Bluetooth state and provides callbacks for:
- Bluetooth power state changes
- Peripheral discovery events
- Connection and disconnection events
- Error conditions

## Best Practices

### Discovery Management

```swift
// Start discovery when Bluetooth is ready
func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState) {
    switch state {
    case .poweredOn:
        middleware.discoverPeripherals()
    case .poweredOff:
        // Handle Bluetooth off state
        break
    default:
        // Handle other states
        break
    }
}

// Stop discovery to save battery
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    middleware.stopDiscovery()
}
```

### Connection Management

```swift
// Connect to discovered peripherals
func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
    // Filter peripherals by name or other criteria
    if peripheral.name?.contains("MyDevice") == true {
        middleware.connectToPeripheral(peripheral)
    }
}

// Handle connection events
func bleMiddleware(_ middleware: BLEMiddleware, didConnectPeripheral peripheral: BLEPeripheral) {
    print("Connected to \(peripheral.name ?? "Unknown")")
    // Peripheral is now ready for communication
}

func bleMiddleware(_ middleware: BLEMiddleware, didDisconnectPeripheral peripheral: BLEPeripheral, error: Error?) {
    if let error = error {
        print("Disconnection error: \(error)")
    } else {
        print("Peripheral disconnected normally")
    }
}
```

## Topics

### Essential Classes
- ``BLEMiddleware``
- ``BLEPeripheral``

### Protocols
- ``BLEMiddlewareDelegate``

### Error Handling
- Connection failures are reported through delegate methods
- State changes provide context for error conditions
- Automatic retry mechanisms can be implemented in delegate methods