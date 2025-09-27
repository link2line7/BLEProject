//
//  BLEPeripheral.swift
//  BLEMiddleware
//
//  Created by antonio on 2025/9/25.
//

import CoreBluetooth
import Foundation

/// Represents a Bluetooth Low Energy peripheral device.
///
/// The `BLEPeripheral` class wraps a Core Bluetooth `CBPeripheral` object and provides
/// a simplified interface for accessing peripheral information and managing connection state.
///
/// Each peripheral is uniquely identified by its UUID and can contain additional information
/// such as device name and manufacturer data from advertisement packets.
///
/// ## Usage Example
///
/// ```swift
/// // Peripheral is typically created by BLEMiddleware during discovery
/// func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
///     print("Discovered: \(peripheral.name ?? "Unknown")")
///     print("ID: \(peripheral.identifier)")
///     
///     // Connect to the peripheral
///     middleware.connectToPeripheral(peripheral)
/// }
/// ```
///
/// ## Topics
///
/// ### Creating a Peripheral
/// - ``init(cbPeripheral:)``
///
/// ### Identification
/// - ``identifier``
/// - ``name``
///
/// ### Advertisement Data
/// - ``manufactureData``
///
/// ### Connection State
/// - ``isConnected``
///
/// ### Core Bluetooth Integration
/// - ``cbPeripheral``
public class BLEPeripheral {
    
    /// The unique identifier for this peripheral.
    ///
    /// This UUID uniquely identifies the peripheral device and remains constant
    /// across app launches and system reboots. Use this identifier to distinguish
    /// between different peripherals.
    ///
    /// - Note: The identifier is assigned by the system and cannot be changed.
    public let identifier: UUID
    
    /// The name of the peripheral, if available.
    ///
    /// Returns the peripheral's advertised name or the name stored in the system.
    /// This value may be `nil` if the peripheral doesn't advertise a name or
    /// if the name is not yet available.
    ///
    /// - Returns: The peripheral's name, or `nil` if not available.
    public var name: String? {
        return cbPeripheral?.name
    }
    
    /// The manufacturer data from the peripheral's advertisement packet.
    ///
    /// This property contains the raw manufacturer-specific data included in
    /// the peripheral's advertisement. The format and content depend on the
    /// device manufacturer.
    ///
    /// - Note: This data is populated during peripheral discovery and may be `nil`
    ///   if the peripheral doesn't include manufacturer data in its advertisement.
    public var manufactureData: Data?
    
    /// Indicates whether this peripheral is currently connected.
    ///
    /// This property is automatically updated by the middleware when connection
    /// state changes. Use this to check the current connection status before
    /// attempting operations that require a connection.
    ///
    /// - Important: This reflects the middleware's view of the connection state.
    ///   The actual Core Bluetooth state may differ in edge cases.
    public var isConnected: Bool = false
    
    /// The underlying Core Bluetooth peripheral object.
    ///
    /// Provides access to the wrapped `CBPeripheral` for advanced operations
    /// not covered by the middleware. Use with caution as direct manipulation
    /// may interfere with middleware operations.
    ///
    /// - Warning: Modifying the CBPeripheral directly may cause unexpected behavior.
    public var cbPeripheral: CBPeripheral?
    
    /// Initializes a BLE peripheral with a Core Bluetooth peripheral.
    ///
    /// Creates a new `BLEPeripheral` instance that wraps the provided `CBPeripheral`.
    /// The peripheral's identifier is extracted and stored for quick access.
    ///
    /// - Parameter cbPeripheral: The Core Bluetooth peripheral to wrap. This should
    ///   be a peripheral discovered through Core Bluetooth scanning.
    ///
    /// - Note: This initializer is typically called by ``BLEMiddleware`` during
    ///   the discovery process. You rarely need to create peripherals manually.
    public init(cbPeripheral: CBPeripheral) {
        self.identifier = cbPeripheral.identifier
        self.cbPeripheral = cbPeripheral
    }
}

extension BLEPeripheral: Equatable {
    public static func == (lhs: BLEPeripheral, rhs: BLEPeripheral) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension BLEPeripheral: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
