# Device Name Stability

Learn how BLEMiddleware handles device name changes and ensures consistent display names.

## Overview

BLE device names can change between discovery and connection phases, which can confuse users. BLEMiddleware provides built-in mechanisms to maintain stable device names throughout the connection lifecycle.

## The Problem

### Why Device Names Change

BLE device names can come from different sources:

1. **Advertisement Data**: Name included in the advertising packet
2. **GATT Service**: Device name stored in the Generic Access Profile service
3. **System Cache**: iOS cached name from previous connections

When a device connects, iOS may update the cached name with information from GATT services, causing the displayed name to change unexpectedly.

### Example Scenario

```swift
// During discovery
peripheral.name // "MyDevice_ADV"

// After connection
peripheral.name // "MyDevice Pro Max Ultra"
```

## BLEMiddleware Solution

### Automatic Name Caching

BLEMiddleware automatically caches the advertised name when a device is first discovered:

```swift
// In BLEMiddleware
public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
    let blePeripheral = BLEPeripheral(cbPeripheral: peripheral)
    
    // Cache advertised device name
    if let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
        blePeripheral.advertisedName = advertisedName
    } else if let currentName = peripheral.name {
        blePeripheral.advertisedName = currentName
    }
}
```

### Smart Display Name Selection

The `BLEPeripheral` class provides a `displayName` property that intelligently selects the most stable name:

```swift
public var displayName: String {
    // Prefer cached advertised name
    if let advertisedName = advertisedName, !advertisedName.isEmpty {
        return advertisedName
    }
    
    // Fall back to current name
    if let currentName = name, !currentName.isEmpty {
        return currentName
    }
    
    // Default fallback
    return "Unknown Device"
}
```

## Usage in Your App

### Displaying Device Names

Always use the `displayName` property for consistent UI display:

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let peripheral = bleMiddleware.discoveredPeripherals[indexPath.row]
    
    // Use displayName for stable device names
    cell.nameLabel.text = peripheral.displayName
    
    return cell
}
```

### Accessing Different Name Sources

You can still access different name sources when needed:

```swift
let peripheral = bleMiddleware.discoveredPeripherals[0]

// Stable display name (recommended for UI)
let displayName = peripheral.displayName

// Current system name (may change after connection)
let currentName = peripheral.name

// Original advertised name (if available)
let advertisedName = peripheral.advertisedName
```

## Best Practices

### 1. Always Use displayName for UI

```swift
// ✅ Good - Stable name
cell.nameLabel.text = peripheral.displayName

// ❌ Avoid - May change after connection
cell.nameLabel.text = peripheral.name
```

### 2. Handle Empty Names Gracefully

```swift
let deviceName = peripheral.displayName.isEmpty ? "Unnamed Device" : peripheral.displayName
```

### 3. Consider Name Preferences

For advanced use cases, you might want to provide user preferences:

```swift
enum NameDisplayPreference {
    case advertised    // Always show advertised name
    case current      // Always show current name
    case stable       // Use displayName logic (default)
}

func getPreferredName(for peripheral: BLEPeripheral, preference: NameDisplayPreference) -> String {
    switch preference {
    case .advertised:
        return peripheral.advertisedName ?? "Unknown Device"
    case .current:
        return peripheral.name ?? "Unknown Device"
    case .stable:
        return peripheral.displayName
    }
}
```

## Implementation Details

### Name Caching Strategy

1. **Discovery Phase**: Cache the first available name from advertisement data
2. **Connection Phase**: Preserve the cached name regardless of system updates
3. **Display Phase**: Use cached name for consistent UI experience

### Memory Management

- Cached names are stored as properties of `BLEPeripheral` instances
- Names are automatically released when peripheral objects are deallocated
- No additional cleanup required

### Thread Safety

- Name caching occurs on the Core Bluetooth queue
- UI updates should always happen on the main queue
- The `displayName` property is thread-safe to read

## Troubleshooting

### Names Still Changing

If you're still seeing name changes:

1. Verify you're using `displayName` instead of `name`
2. Check if the device is being rediscovered (creating new instances)
3. Ensure proper peripheral instance management

### Empty or Missing Names

Some devices don't advertise names:

```swift
// Handle devices without names
let displayText = peripheral.displayName.isEmpty ? 
    "Device \(peripheral.identifier.uuidString.prefix(8))" : 
    peripheral.displayName
```

### Performance Considerations

- Name caching has minimal memory overhead
- String comparisons are optimized for common cases
- No impact on discovery or connection performance

By following these guidelines, your app will provide a consistent and user-friendly device naming experience.