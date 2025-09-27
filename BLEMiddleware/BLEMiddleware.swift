//
//  BLEMiddleware.swift
//  BLEMiddleware
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
/// Use this class to:
/// - Discover nearby BLE peripherals
/// - Connect to and disconnect from peripherals
/// - Monitor Bluetooth state changes
/// - Receive notifications about peripheral events
///
/// ## Usage Example
///
/// ```swift
/// let middleware = BLEMiddleware()
/// middleware.delegate = self
/// middleware.discoverPeripherals()
/// ```
///
/// ## Important Notes
///
/// - Ensure Bluetooth permissions are granted in your app's Info.plist
/// - The middleware automatically manages the underlying CBCentralManager
/// - All delegate callbacks are called on the main queue
///
/// ## Topics
///
/// ### Creating a Middleware Instance
/// - ``init()``
///
/// ### Managing Discovery
/// - ``discoverPeripherals()``
/// - ``stopDiscovery()``
///
/// ### Managing Connections
/// - ``connectToPeripheral(_:)``
/// - ``disconnectFromPeripheral(_:)``
///
/// ### Accessing Peripherals
/// - ``discoveredPeripherals``
/// - ``connectedPeripherals``
///
/// ### Delegate Communication
/// - ``delegate``
/// - ``BLEMiddlewareDelegate``
public class BLEMiddleware: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    /// The delegate object that receives middleware events.
    ///
    /// Set this property to receive notifications about Bluetooth state changes,
    /// peripheral discovery, connection events, and disconnection events.
    ///
    /// - Important: The delegate methods are called on the main queue.
    public weak var delegate: BLEMiddlewareDelegate?
    
    private var centralManager: CBCentralManager!
    private var _discoveredPeripherals: [BLEPeripheral] = []
    private var _connectedPeripherals: [BLEPeripheral] = []
    
    /// Array of discovered BLE peripherals.
    ///
    /// This array contains all peripherals that have been discovered during scanning.
    /// Peripherals remain in this array even after scanning stops, until the middleware
    /// instance is deallocated.
    ///
    /// - Returns: An array of ``BLEPeripheral`` objects representing discovered devices.
    public var discoveredPeripherals: [BLEPeripheral] {
        return _discoveredPeripherals
    }
    
    /// Array of currently connected BLE peripherals.
    ///
    /// This array contains only peripherals that are currently connected.
    /// When a peripheral disconnects, it is automatically removed from this array.
    ///
    /// - Returns: An array of ``BLEPeripheral`` objects representing connected devices.
    public var connectedPeripherals: [BLEPeripheral] {
        return _connectedPeripherals
    }
    
    /// Initializes a new BLE middleware instance.
    ///
    /// Creates a central manager and sets up the middleware for BLE operations.
    /// The central manager will automatically check for Bluetooth availability and
    /// notify the delegate of the initial state.
    ///
    /// - Note: The initialization process is asynchronous. Wait for the
    ///   ``BLEMiddlewareDelegate/bleMiddleware(_:didUpdateState:)`` callback
    ///   with `.poweredOn` state before starting operations.
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// Starts discovering BLE peripherals.
    ///
    /// Begins scanning for nearby BLE devices. Discovered devices will be added to
    /// the ``discoveredPeripherals`` array and reported through the
    /// ``BLEMiddlewareDelegate/bleMiddleware(_:didDiscoverPeripheral:)`` delegate method.
    ///
    /// The scan continues until ``stopDiscovery()`` is called or the app is backgrounded.
    /// Duplicate discoveries of the same peripheral are automatically filtered out.
    ///
    /// - Important: Bluetooth must be powered on before calling this method.
    ///   Check the state via the delegate callback before starting discovery.
    ///
    /// - Note: Scanning consumes battery power. Stop scanning when not needed.
    public func discoverPeripherals() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /// Stops the peripheral discovery process.
    ///
    /// Call this method to stop scanning for BLE peripherals. This helps conserve
    /// battery power when discovery is no longer needed.
    ///
    /// Previously discovered peripherals remain in the ``discoveredPeripherals`` array.
    public func stopDiscovery() {
        centralManager.stopScan()
    }
    
    /// Connects to a specified BLE peripheral.
    ///
    /// Initiates a connection to the specified peripheral. The connection result
    /// will be reported through the delegate methods:
    /// - ``BLEMiddlewareDelegate/bleMiddleware(_:didConnectPeripheral:)`` on success
    /// - ``BLEMiddlewareDelegate/bleMiddleware(_:didDisconnectPeripheral:error:)`` on failure
    ///
    /// - Parameter peripheral: The BLE peripheral to connect to. Must be a peripheral
    ///   from the ``discoveredPeripherals`` array.
    ///
    /// - Important: The peripheral must have been discovered before attempting connection.
    public func connectToPeripheral(_ peripheral: BLEPeripheral) {
        guard let cbPeripheral = peripheral.cbPeripheral else { return }
        centralManager.connect(cbPeripheral, options: nil)
    }
    
    /// Disconnects from a specified BLE peripheral.
    ///
    /// Terminates the connection to the specified peripheral. The disconnection
    /// will be reported through the
    /// ``BLEMiddlewareDelegate/bleMiddleware(_:didDisconnectPeripheral:error:)`` delegate method.
    ///
    /// - Parameter peripheral: The BLE peripheral to disconnect from. Must be a peripheral
    ///   from the ``connectedPeripherals`` array.
    ///
    /// - Note: If the peripheral is not connected, this method has no effect.
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
            // Cache advertisement data
            blePeripheral.manufactureData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
            
            // Cache advertised device name
            if let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
                blePeripheral.advertisedName = advertisedName
            } else if let currentName = peripheral.name {
                blePeripheral.advertisedName = currentName
            }
            
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
