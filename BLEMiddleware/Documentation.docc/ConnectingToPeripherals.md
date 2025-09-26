# Connecting to Peripherals

Learn how to establish connections with discovered BLE devices.

## Overview

Once you've discovered BLE peripherals, you can establish connections to interact with them. The BLEMiddleware framework simplifies the connection process and provides clear feedback through delegate methods.

### Establishing a Connection

To connect to a discovered peripheral, use the ``BLEMiddleware/connectToPeripheral(_:)`` method:

```swift
let peripheral = bleMiddleware.discoveredPeripherals.first
if let peripheral = peripheral {
    bleMiddleware.connectToPeripheral(peripheral)
}
```

### Connection Success

When a connection is successfully established, the delegate method ``BLEMiddlewareDelegate/bleMiddleware(_:didConnectPeripheral:)`` is called:

```swift
func bleMiddleware(_ middleware: BLEMiddleware, didConnectPeripheral peripheral: BLEPeripheral) {
    print("Connected to: \(peripheral.name ?? "Unknown Device")")
    // The peripheral is now ready for communication
}
```

### Checking Connection Status

You can check if a peripheral is connected using the ``BLEPeripheral/isConnected`` property:

```swift
if peripheral.isConnected {
    print("Device is connected")
} else {
    print("Device is not connected")
}
```

### Accessing Connected Peripherals

All connected peripherals are available through the ``BLEMiddleware/connectedPeripherals`` array:

```swift
let connectedDevices = bleMiddleware.connectedPeripherals
print("Connected devices: \(connectedDevices.count)")
```

### Connection Considerations

- Connections may fail due to various reasons (device out of range, interference, etc.)
- Always implement the disconnect delegate method to handle unexpected disconnections
- BLE connections have a limited range (typically 10-100 meters depending on the device)
- Some devices may have connection limits or require specific pairing procedures

### Error Handling

While the connection method doesn't directly return errors, connection failures are typically handled through the absence of a connection success callback. Monitor your app's behavior and implement appropriate timeouts if needed.