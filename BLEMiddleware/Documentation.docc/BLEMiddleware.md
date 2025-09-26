# ``BLEMiddleware``

A Swift framework for simplified Bluetooth Low Energy operations.

## Overview

The BLEMiddleware framework provides a high-level interface for interacting with Bluetooth Low Energy (BLE) devices. It abstracts the complexity of Core Bluetooth and offers a simple, delegate-based API for discovering, connecting to, and managing BLE peripherals.

### Key Features

- **Simple API**: Easy-to-use methods for common BLE operations
- **Delegate Pattern**: Receive callbacks for BLE events and state changes
- **Peripheral Management**: Track discovered and connected devices
- **Thread Safety**: All delegate callbacks are properly dispatched

### Getting Started

To use BLEMiddleware in your project:

1. Import the framework
2. Create a BLEMiddleware instance
3. Set yourself as the delegate
4. Start discovering peripherals

```swift
import BLEMiddleware

class MyViewController: UIViewController, BLEMiddlewareDelegate {
    let bleMiddleware = BLEMiddleware()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bleMiddleware.delegate = self
        bleMiddleware.discoverPeripherals()
    }
    
    // Implement delegate methods...
}
```

## Topics

### Core Classes

- ``BLEMiddleware``
- ``BLEPeripheral``

### Protocols

- ``BLEMiddlewareDelegate``

### Peripheral Management

- <doc:DiscoveringPeripherals>
- <doc:ConnectingToPeripherals>
- <doc:ManagingConnections>