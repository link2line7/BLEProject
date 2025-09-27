# Getting Started with BLEMiddleware

Learn how to integrate and use BLEMiddleware in your iOS application.

## Overview

BLEMiddleware simplifies Bluetooth Low Energy development by providing a high-level interface over Core Bluetooth. This guide walks you through the essential steps to get started.

## Installation

### Swift Package Manager

Add BLEMiddleware to your project using Swift Package Manager:

1. In Xcode, go to File → Add Package Dependencies
2. Enter the repository URL
3. Select the version and add to your target

### Manual Integration

1. Drag the BLEMiddleware folder into your Xcode project
2. Ensure the files are added to your target
3. Import the framework where needed

## Basic Implementation

### Step 1: Import and Initialize

```swift
import BLEMiddleware

class BluetoothManager: NSObject {
    private let middleware = BLEMiddleware()
    
    override init() {
        super.init()
        middleware.delegate = self
    }
}
```

### Step 2: Implement Delegate Methods

```swift
extension BluetoothManager: BLEMiddlewareDelegate {
    func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState) {
        switch state {
        case .poweredOn:
            print("Bluetooth is ready")
            middleware.discoverPeripherals()
        case .poweredOff:
            print("Bluetooth is off")
        case .unauthorized:
            print("Bluetooth access denied")
        default:
            print("Bluetooth state: \(state)")
        }
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
        print("Found device: \(peripheral.name ?? "Unknown")")
        
        // Example: Connect to devices with specific name
        if peripheral.name?.contains("MyDevice") == true {
            middleware.connectToPeripheral(peripheral)
        }
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didConnectPeripheral peripheral: BLEPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        // Device is ready for communication
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDisconnectPeripheral peripheral: BLEPeripheral, error: Error?) {
        if let error = error {
            print("Connection lost: \(error.localizedDescription)")
        } else {
            print("Disconnected normally")
        }
    }
}
```

### Step 3: Configure Permissions

Add Bluetooth usage description to your `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to external devices.</string>
```

## Common Patterns

### Filtering Discovered Devices

```swift
func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
    // Filter by name
    guard let name = peripheral.name,
          name.hasPrefix("MyDevice") else { return }
    
    // Filter by manufacturer data
    if let manufacturerData = peripheral.manufactureData {
        // Check manufacturer-specific data
        let companyID = manufacturerData.prefix(2)
        // Process based on company identifier
    }
    
    // Connect to filtered device
    middleware.connectToPeripheral(peripheral)
}
```

### Managing Discovery Lifecycle

```swift
class ViewController: UIViewController {
    private let bluetoothManager = BluetoothManager()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start discovery when view appears
        bluetoothManager.startDiscovery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop discovery to save battery
        bluetoothManager.stopDiscovery()
    }
}
```

### Connection State Management

```swift
class DeviceManager {
    private var connectedDevices: [BLEPeripheral] = []
    
    func bleMiddleware(_ middleware: BLEMiddleware, didConnectPeripheral peripheral: BLEPeripheral) {
        connectedDevices.append(peripheral)
        notifyConnectionStateChanged()
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDisconnectPeripheral peripheral: BLEPeripheral, error: Error?) {
        connectedDevices.removeAll { $0.identifier == peripheral.identifier }
        
        if let error = error {
            // Handle unexpected disconnection
            handleConnectionError(error, for: peripheral)
        }
        
        notifyConnectionStateChanged()
    }
    
    private func handleConnectionError(_ error: Error, for peripheral: BLEPeripheral) {
        // Implement retry logic or user notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Attempt reconnection
            self.middleware.connectToPeripheral(peripheral)
        }
    }
}
```

## Next Steps

- Explore the ``BLEMiddleware`` class documentation for advanced features
- Learn about ``BLEPeripheral`` properties and methods
- Review the ``BLEMiddlewareDelegate`` protocol for all available callbacks
- Check out the example projects for complete implementations