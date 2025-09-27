# Error Handling and Troubleshooting

Learn how to handle errors and troubleshoot common issues with BLEMiddleware.

## Overview

BLEMiddleware provides comprehensive error handling through delegate methods and state management. Understanding these mechanisms helps you build robust BLE applications.

## Error Types and Handling

### Bluetooth State Errors

Monitor Bluetooth state changes to handle system-level issues:

```swift
func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState) {
    switch state {
    case .poweredOn:
        // Bluetooth is ready
        middleware.discoverPeripherals()
        
    case .poweredOff:
        // Show user alert to enable Bluetooth
        showBluetoothOffAlert()
        
    case .unauthorized:
        // Request Bluetooth permissions
        showPermissionAlert()
        
    case .unsupported:
        // Device doesn't support Bluetooth LE
        showUnsupportedAlert()
        
    case .resetting:
        // Bluetooth is resetting, wait for next state update
        showTemporaryUnavailableMessage()
        
    default:
        // Handle unknown states
        print("Unknown Bluetooth state: \(state)")
    }
}
```

### Connection Errors

Handle connection failures through the disconnection delegate method:

```swift
func bleMiddleware(_ middleware: BLEMiddleware, didDisconnectPeripheral peripheral: BLEPeripheral, error: Error?) {
    if let error = error {
        handleConnectionError(error, peripheral: peripheral)
    } else {
        // Normal disconnection
        print("Peripheral disconnected normally")
    }
}

private func handleConnectionError(_ error: Error, peripheral: BLEPeripheral) {
    let nsError = error as NSError
    
    switch nsError.code {
    case CBError.peripheralDisconnected.rawValue:
        // Peripheral disconnected unexpectedly
        attemptReconnection(peripheral)
        
    case CBError.connectionTimeout.rawValue:
        // Connection attempt timed out
        showTimeoutError(for: peripheral)
        
    case CBError.connectionFailed.rawValue:
        // Connection failed to establish
        showConnectionFailedError(for: peripheral)
        
    default:
        // Other connection errors
        showGenericConnectionError(error, for: peripheral)
    }
}
```

## Common Issues and Solutions

### Issue: Peripherals Not Discovered

**Symptoms**: No peripherals appear in discovery results

**Possible Causes**:
- Bluetooth is not powered on
- App lacks Bluetooth permissions
- Peripherals are not advertising
- Peripherals are out of range

**Solutions**:

```swift
func troubleshootDiscovery() {
    // Check Bluetooth state
    guard middleware.centralManager.state == .poweredOn else {
        print("Bluetooth not ready: \(middleware.centralManager.state)")
        return
    }
    
    // Verify permissions in Info.plist
    // NSBluetoothAlwaysUsageDescription must be present
    
    // Try discovery with specific services
    middleware.discoverPeripherals(withServices: [CBUUID(string: "180A")])
    
    // Increase discovery timeout
    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
        if self.middleware.discoveredPeripherals.isEmpty {
            self.showNoDevicesFoundAlert()
        }
    }
}
```

### Issue: Connection Failures

**Symptoms**: Connections fail or disconnect immediately

**Possible Causes**:
- Peripheral is already connected to another device
- Signal strength is too weak
- Peripheral has connection limits
- iOS connection cache issues

**Solutions**:

```swift
class ConnectionManager {
    private var connectionAttempts: [UUID: Int] = [:]
    private let maxRetries = 3
    
    func connectWithRetry(_ peripheral: BLEPeripheral) {
        let attempts = connectionAttempts[peripheral.identifier] ?? 0
        
        guard attempts < maxRetries else {
            showMaxRetriesReached(for: peripheral)
            return
        }
        
        connectionAttempts[peripheral.identifier] = attempts + 1
        middleware.connectToPeripheral(peripheral)
        
        // Set connection timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if !peripheral.isConnected {
                self.handleConnectionTimeout(peripheral)
            }
        }
    }
    
    private func handleConnectionTimeout(_ peripheral: BLEPeripheral) {
        middleware.disconnectFromPeripheral(peripheral)
        
        // Wait before retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.connectWithRetry(peripheral)
        }
    }
}
```

### Issue: Memory and Performance Problems

**Symptoms**: App becomes slow or crashes during BLE operations

**Solutions**:

```swift
class OptimizedBLEManager {
    private let middleware = BLEMiddleware()
    private var discoveryTimer: Timer?
    
    func startOptimizedDiscovery() {
        // Limit discovery time to save battery
        middleware.discoverPeripherals()
        
        discoveryTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { _ in
            self.middleware.stopDiscovery()
        }
    }
    
    func cleanupDisconnectedPeripherals() {
        // Remove references to disconnected peripherals
        let connectedIDs = Set(middleware.connectedPeripherals.map { $0.identifier })
        
        // Clean up any cached data for disconnected peripherals
        cachedPeripheralData = cachedPeripheralData.filter { connectedIDs.contains($0.key) }
    }
    
    deinit {
        // Always stop discovery when deallocating
        middleware.stopDiscovery()
        discoveryTimer?.invalidate()
    }
}
```

## Best Practices for Error Handling

### 1. Implement Comprehensive State Monitoring

```swift
class RobustBLEManager: BLEMiddlewareDelegate {
    private var isBluetoothReady: Bool = false
    
    func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState) {
        isBluetoothReady = (state == .poweredOn)
        
        // Notify UI of state changes
        NotificationCenter.default.post(
            name: .bluetoothStateChanged,
            object: state
        )
    }
    
    func startDiscoveryIfReady() {
        guard isBluetoothReady else {
            showBluetoothNotReadyAlert()
            return
        }
        
        middleware.discoverPeripherals()
    }
}
```

### 2. Implement User-Friendly Error Messages

```swift
extension BLEManager {
    private func showUserFriendlyError(_ error: Error) {
        let message: String
        
        if let bleError = error as? CBError {
            switch bleError.code {
            case .connectionTimeout:
                message = "Connection timed out. Please move closer to the device and try again."
            case .peripheralDisconnected:
                message = "Device disconnected unexpectedly. Attempting to reconnect..."
            default:
                message = "Bluetooth connection error. Please try again."
            }
        } else {
            message = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        DispatchQueue.main.async {
            self.showAlert(title: "Connection Error", message: message)
        }
    }
}
```

### 3. Implement Graceful Degradation

```swift
class AdaptiveBLEManager {
    private var connectionQuality: ConnectionQuality = .unknown
    
    enum ConnectionQuality {
        case excellent, good, poor, unknown
    }
    
    func adaptToConnectionQuality() {
        switch connectionQuality {
        case .excellent:
            // Use full feature set
            enableAllFeatures()
        case .good:
            // Reduce update frequency
            setReducedUpdateRate()
        case .poor:
            // Minimal functionality only
            enableEssentialFeaturesOnly()
        case .unknown:
            // Conservative approach
            useDefaultSettings()
        }
    }
}
```

## Debugging Tips

### Enable Detailed Logging

```swift
extension BLEMiddleware {
    func enableDebugLogging() {
        // Add logging to delegate methods
        print("BLE Debug: Middleware initialized")
    }
}
```

### Monitor System Resources

```swift
class BLEResourceMonitor {
    func logMemoryUsage() {
        let info = mach_task_basic_info()
        // Log memory usage during BLE operations
    }
    
    func logBatteryImpact() {
        // Monitor battery usage during scanning
    }
}
```

By following these error handling patterns and troubleshooting guidelines, you can build robust BLE applications that gracefully handle various failure scenarios and provide a smooth user experience.