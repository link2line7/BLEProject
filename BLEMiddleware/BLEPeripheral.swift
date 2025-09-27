//
//  ViewController.swift
//  BLEAPP
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
/// ## Topics
///
/// ### Creating a Peripheral
/// - ``init(cbPeripheral:)``
///
/// ### Peripheral Properties
/// - ``identifier``
/// - ``name``
/// - ``manufactureData``
/// - ``isConnected``
/// - ``cbPeripheral``
public class BLEPeripheral {
    
    /// The unique identifier for this peripheral.
    public let identifier: UUID
    
    /// The name of the peripheral, if available.
    public var name: String? {
        return cbPeripheral?.name
    }
    
    /// The manufactureData of the peripheral, if available.
    public var manufactureData: Data?
    
    /// Indicates whether this peripheral is currently connected.
    public var isConnected: Bool = false
    
    /// The underlying Core Bluetooth peripheral object.
    public var cbPeripheral: CBPeripheral?
    
    /// Initializes a BLE peripheral with a Core Bluetooth peripheral.
    ///
    /// - Parameter cbPeripheral: The Core Bluetooth peripheral to wrap.
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
