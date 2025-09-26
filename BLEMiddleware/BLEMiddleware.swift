//
//  ViewController.swift
//  BLEAPP
//
//  Created by antonio on 2025/9/25.
//

import CoreBluetooth
import Foundation

/// A middleware class that provides a simplified interface for Bluetooth Low Energy operations.
/// 
/// The `BLEMiddleware` class acts as a central manager for BLE operations, handling device discovery,
/// connection management, and peripheral interactions. It implements the Core Bluetooth delegate
/// protocols to manage the underlying Bluetooth operations.
///
/// ## Topics
///
/// ### Creating a Middleware Instance
/// - ``init()``
///
/// ### Managing Peripherals
/// - ``discoverPeripherals()``
/// - ``stopDiscovery()``
/// - ``connectToPeripheral(_:)``
/// - ``disconnectFromPeripheral(_:)``
///
/// ### Accessing Discovered Peripherals
/// - ``discoveredPeripherals``
/// - ``connectedPeripherals``
///
/// ### Delegate Methods
/// - ``BLEMiddlewareDelegate``
public class BLEMiddleware: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    /// Delegate to receive BLE middleware events
    public weak var delegate: BLEMiddlewareDelegate?
    
    private var centralManager: CBCentralManager!
    private var _discoveredPeripherals: [BLEPeripheral] = []
    private var _connectedPeripherals: [BLEPeripheral] = []
    
    /// Array of discovered BLE peripherals
    public var discoveredPeripherals: [BLEPeripheral] {
        return _discoveredPeripherals
    }
    
    /// Array of connected BLE peripherals
    public var connectedPeripherals: [BLEPeripheral] {
        return _connectedPeripherals
    }
    
    /// Initializes a new BLE middleware instance.
    ///
    /// Creates a central manager and sets up the middleware for BLE operations.
    /// The central manager will automatically check for Bluetooth availability.
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// Starts discovering BLE peripherals.
    ///
    /// Begins scanning for nearby BLE devices. Discovered devices will be added to
    /// the `discoveredPeripherals` array and reported through the delegate.
    ///
    /// - Note: Bluetooth must be powered on before calling this method.
    public func discoverPeripherals() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /// Stops the peripheral discovery process.
    public func stopDiscovery() {
        centralManager.stopScan()
    }
    
    /// Connects to a specified BLE peripheral.
    ///
    /// - Parameter peripheral: The BLE peripheral to connect to.
    public func connectToPeripheral(_ peripheral: BLEPeripheral) {
        guard let cbPeripheral = peripheral.cbPeripheral else { return }
        centralManager.connect(cbPeripheral, options: nil)
    }
    
    /// Disconnects from a specified BLE peripheral.
    ///
    /// - Parameter peripheral: The BLE peripheral to disconnect from.
    public func disconnectFromPeripheral(_ peripheral: BLEPeripheral) {
        guard let cbPeripheral = peripheral.cbPeripheral else { return }
        centralManager.cancelPeripheralConnection(cbPeripheral)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.bleMiddleware(self, didUpdateState: central.state)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let blePeripheral = BLEPeripheral(cbPeripheral: peripheral)
        
        if !_discoveredPeripherals.contains(where: { $0.identifier == blePeripheral.identifier }) {
            _discoveredPeripherals.append(blePeripheral)
            delegate?.bleMiddleware(self, didDiscoverPeripheral: blePeripheral)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let blePeripheral = _discoveredPeripherals.first(where: { $0.identifier == peripheral.identifier }) {
            blePeripheral.isConnected = true
            if !_connectedPeripherals.contains(where: { $0.identifier == blePeripheral.identifier }) {
                _connectedPeripherals.append(blePeripheral)
            }
            delegate?.bleMiddleware(self, didConnectPeripheral: blePeripheral)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let blePeripheral = _discoveredPeripherals.first(where: { $0.identifier == peripheral.identifier }) {
            blePeripheral.isConnected = false
            _connectedPeripherals.removeAll { $0.identifier == blePeripheral.identifier }
            delegate?.bleMiddleware(self, didDisconnectPeripheral: blePeripheral, error: error)
        }
    }
}

/// Protocol for receiving BLE middleware events.
///
/// Implement this protocol to receive notifications about BLE state changes,
/// peripheral discovery, and connection events.
public protocol BLEMiddlewareDelegate: AnyObject {
    
    /// Called when the central manager's state changes.
    ///
    /// - Parameters:
    ///   - middleware: The BLE middleware instance.
    ///   - state: The new state of the central manager.
    func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState)
    
    /// Called when a new peripheral is discovered.
    ///
    /// - Parameters:
    ///   - middleware: The BLE middleware instance.
    ///   - peripheral: The discovered peripheral.
    func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral)
    
    /// Called when a peripheral is successfully connected.
    ///
    /// - Parameters:
    ///   - middleware: The BLE middleware instance.
    ///   - peripheral: The connected peripheral.
    func bleMiddleware(_ middleware: BLEMiddleware, didConnectPeripheral peripheral: BLEPeripheral)
    
    /// Called when a peripheral is disconnected.
    ///
    /// - Parameters:
    ///   - middleware: The BLE middleware instance.
    ///   - peripheral: The disconnected peripheral.
    ///   - error: An error if the disconnection was unexpected.
    func bleMiddleware(_ middleware: BLEMiddleware, didDisconnectPeripheral peripheral: BLEPeripheral, error: Error?)
}
