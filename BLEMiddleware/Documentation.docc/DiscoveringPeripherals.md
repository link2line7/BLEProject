# Discovering Peripherals

Learn how to discover nearby BLE devices using the BLEMiddleware framework.

## Overview

The BLEMiddleware framework makes it easy to discover nearby Bluetooth Low Energy devices. The discovery process is managed through simple method calls and delegate callbacks.

### Starting Discovery

To begin discovering peripherals, call the ``BLEMiddleware/discoverPeripherals()`` method:

```swift
bleMiddleware.discoverPeripherals()
```

**Important**: Ensure that Bluetooth is powered on before starting discovery. You can check the Bluetooth state through the delegate method ``BLEMiddlewareDelegate/bleMiddleware(_:didUpdateState:)``.

### Receiving Discovery Results

When peripherals are discovered, the delegate method ``BLEMiddlewareDelegate/bleMiddleware(_:didDiscoverPeripheral:)`` is called:

```swift
func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
    print("Discovered: \(peripheral.name ?? "Unknown Device")")
    // Update your UI or store the peripheral
}
```

### Accessing Discovered Peripherals

All discovered peripherals are stored in the ``BLEMiddleware/discoveredPeripherals`` array:

```swift
let peripherals = bleMiddleware.discoveredPeripherals
for peripheral in peripherals {
    print("Device: \(peripheral.name ?? "Unknown") - ID: \(peripheral.identifier)")
}
```

### Stopping Discovery

To stop the discovery process and conserve battery:

```swift
bleMiddleware.stopDiscovery()
```

### Best Practices

- Always stop discovery when not needed to preserve battery life
- Check Bluetooth state before starting discovery
- Handle the case where no peripherals are found
- Consider filtering peripherals based on your app's requirements