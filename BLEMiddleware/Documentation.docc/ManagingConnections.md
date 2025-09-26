# Managing Connections

Learn how to manage and terminate BLE connections effectively.

## Overview

Proper connection management is crucial for BLE applications. This includes handling disconnections, monitoring connection state, and cleaning up resources when connections are no longer needed.

### Disconnecting from Peripherals

To disconnect from a connected peripheral, use the ``BLEMiddleware/disconnectFromPeripheral(_:)`` method:

```swift
let connectedPeripheral = bleMiddleware.connectedPeripherals.first
if let peripheral = connectedPeripheral {
    bleMiddleware.disconnectFromPeripheral(peripheral)
}
```

### Handling Disconnections

When a peripheral disconnects (either intentionally or unexpectedly), the delegate method ``BLEMiddlewareDelegate/bleMiddleware(_:didDisconnectPeripheral:error:)`` is called:

```swift
func bleMiddleware(_ middleware: BLEMiddleware, didDisconnectPeripheral peripheral: BLEPeripheral, error: Error?) {
    if let error = error {
        print("Unexpected disconnection: \(error.localizedDescription)")
    } else {
        print("Peripheral disconnected successfully")
    }
}
```

### Connection State Monitoring

Monitor the overall Bluetooth state through the ``BLEMiddlewareDelegate/bleMiddleware(_:didUpdateState:)`` delegate method:

```swift
func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState) {
    switch state {
    case .poweredOn:
        print("Bluetooth is ready")
    case .poweredOff:
        print("Bluetooth is turned off")
    case .unauthorized:
        print("Bluetooth access not authorized")
    case .unsupported:
        print("Bluetooth not supported on this device")
    default:
        print("Bluetooth state unknown")
    }
}
```

### Best Practices for Connection Management

1. **Clean Disconnections**: Always disconnect from peripherals when your app no longer needs them
2. **Handle Unexpected Disconnections**: Implement proper error handling for unexpected disconnections
3. **Resource Management**: Disconnect from peripherals when your app goes to the background
4. **Connection Limits**: Be aware that iOS has limits on simultaneous BLE connections
5. **Battery Optimization**: Disconnect when not actively using the peripheral to save battery

### Connection Lifecycle

A typical BLE connection lifecycle in your app might look like:

1. Start discovery
2. Discover peripherals
3. Connect to desired peripheral
4. Use the peripheral for data exchange
5. Disconnect when done
6. Stop discovery to save battery

### Error Recovery

When handling connection errors:

- Implement retry logic for temporary connection failures
- Provide user feedback for persistent connection issues
- Consider automatic reconnection for critical peripherals
- Handle cases where peripherals become unavailable