# Documentation for BLEMiddleware API

# BLEMiddleware

The `BLEMiddleware` module provides a set of functionalities for discovering, connecting, and disconnecting from Bluetooth Low Energy (BLE) peripherals. This documentation outlines the classes, methods, and properties available in the middleware.

## Classes

### BLEMiddleware

The `BLEMiddleware` class is the core component of the middleware, responsible for managing BLE operations.

#### Methods

- **discoverPeripherals()**
  
  Initiates the discovery of nearby BLE peripherals. This method scans for available devices and updates the internal list of discovered peripherals.

- **connectToPeripheral(peripheral: BLEPeripheral)**

  Connects to a specified BLE peripheral. This method establishes a connection and updates the peripheral's state to connected.

- **disconnectFromPeripheral(peripheral: BLEPeripheral)**

  Disconnects from a specified BLE peripheral. This method terminates the connection and updates the peripheral's state to disconnected.

### BLEPeripheral

The `BLEPeripheral` class represents a discovered BLE peripheral.

#### Properties

- **identifier**: `UUID`
  
  A unique identifier for the peripheral.

- **name**: `String?`
  
  The name of the peripheral, if available.

- **isConnected**: `Bool`
  
  A Boolean value indicating whether the peripheral is currently connected.

#### Initializers

- **init(identifier: UUID, name: String?)**

  Initializes a new instance of `BLEPeripheral` with the specified identifier and name.

## Usage Example

To use the `BLEMiddleware`, create an instance of the `BLEMiddleware` class and call its methods to manage BLE peripherals.

```swift
let bleMiddleware = BLEMiddleware()
bleMiddleware.discoverPeripherals()
```

This will start scanning for available BLE devices. Once discovered, you can connect to a peripheral using its instance.

## Conclusion

The `BLEMiddleware` API provides a straightforward interface for managing BLE connections in your iOS applications. For further details, refer to the method and property descriptions above.