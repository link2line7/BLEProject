//
//  ViewController.swift
//  BLEAPP
//
//  Created by antonio on 2025/9/25.
//

import XCTest
import CoreBluetooth
@testable import BLEMiddleware

class BLEMiddlewareTests: XCTestCase {
    
    var middleware: BLEMiddleware!
    var mockDelegate: MockBLEMiddlewareDelegate!
    
    override func setUpWithError() throws {
        middleware = BLEMiddleware()
        mockDelegate = MockBLEMiddlewareDelegate()
        middleware.delegate = mockDelegate
    }
    
    override func tearDownWithError() throws {
        middleware = nil
        mockDelegate = nil
    }
    
    func testMiddlewareInitialization() {
        XCTAssertNotNil(middleware)
        XCTAssertEqual(middleware.discoveredPeripherals.count, 0)
        XCTAssertEqual(middleware.connectedPeripherals.count, 0)
    }
    
    func testDelegateAssignment() {
        XCTAssertNotNil(middleware.delegate)
        XCTAssertTrue(middleware.delegate === mockDelegate)
    }
    
    func testDiscoveredPeripheralsInitiallyEmpty() {
        XCTAssertTrue(middleware.discoveredPeripherals.isEmpty)
    }
    
    func testConnectedPeripheralsInitiallyEmpty() {
        XCTAssertTrue(middleware.connectedPeripherals.isEmpty)
    }
    
    func testPeripheralDiscovery() {
        let mockCBPeripheral = MockCBPeripheral()
        let advertisementData: [String: Any] = [:]
        let rssi = NSNumber(value: -50)
        
        middleware.centralManager(middleware.centralManager, didDiscover: mockCBPeripheral, advertisementData: advertisementData, rssi: rssi)
        
        XCTAssertEqual(middleware.discoveredPeripherals.count, 1)
        XCTAssertEqual(middleware.discoveredPeripherals.first?.identifier, mockCBPeripheral.identifier)
        XCTAssertTrue(mockDelegate.didDiscoverPeripheralCalled)
    }
    
    func testDuplicatePeripheralDiscovery() {
        let mockCBPeripheral = MockCBPeripheral()
        let advertisementData: [String: Any] = [:]
        let rssi = NSNumber(value: -50)
        
        // Discover the same peripheral twice
        middleware.centralManager(middleware.centralManager, didDiscover: mockCBPeripheral, advertisementData: advertisementData, rssi: rssi)
        middleware.centralManager(middleware.centralManager, didDiscover: mockCBPeripheral, advertisementData: advertisementData, rssi: rssi)
        
        // Should only have one peripheral
        XCTAssertEqual(middleware.discoveredPeripherals.count, 1)
    }
    
    func testPeripheralConnection() {
        let mockCBPeripheral = MockCBPeripheral()
        let advertisementData: [String: Any] = [:]
        let rssi = NSNumber(value: -50)
        
        // First discover the peripheral
        middleware.centralManager(middleware.centralManager, didDiscover: mockCBPeripheral, advertisementData: advertisementData, rssi: rssi)
        
        // Then connect to it
        middleware.centralManager(middleware.centralManager, didConnect: mockCBPeripheral)
        
        XCTAssertEqual(middleware.connectedPeripherals.count, 1)
        XCTAssertTrue(middleware.discoveredPeripherals.first?.isConnected ?? false)
        XCTAssertTrue(mockDelegate.didConnectPeripheralCalled)
    }
    
    func testPeripheralDisconnection() {
        let mockCBPeripheral = MockCBPeripheral()
        let advertisementData: [String: Any] = [:]
        let rssi = NSNumber(value: -50)
        
        // Discover and connect
        middleware.centralManager(middleware.centralManager, didDiscover: mockCBPeripheral, advertisementData: advertisementData, rssi: rssi)
        middleware.centralManager(middleware.centralManager, didConnect: mockCBPeripheral)
        
        // Then disconnect
        middleware.centralManager(middleware.centralManager, didDisconnectPeripheral: mockCBPeripheral, error: nil)
        
        XCTAssertEqual(middleware.connectedPeripherals.count, 0)
        XCTAssertFalse(middleware.discoveredPeripherals.first?.isConnected ?? true)
        XCTAssertTrue(mockDelegate.didDisconnectPeripheralCalled)
    }
    
    func testStateUpdate() {
        middleware.centralManagerDidUpdateState(middleware.centralManager)
        XCTAssertTrue(mockDelegate.didUpdateStateCalled)
    }
}

// MARK: - Mock Classes

class MockBLEMiddlewareDelegate: BLEMiddlewareDelegate {
    var didUpdateStateCalled = false
    var didDiscoverPeripheralCalled = false
    var didConnectPeripheralCalled = false
    var didDisconnectPeripheralCalled = false
    
    func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState) {
        didUpdateStateCalled = true
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
        didDiscoverPeripheralCalled = true
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didConnectPeripheral peripheral: BLEPeripheral) {
        didConnectPeripheralCalled = true
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDisconnectPeripheral peripheral: BLEPeripheral, error: Error?) {
        didDisconnectPeripheralCalled = true
    }
}

class MockCBPeripheral: CBPeripheral {
    private let mockIdentifier = UUID()
    
    override var identifier: UUID {
        return mockIdentifier
    }
    
    override var name: String? {
        return "Mock Device"
    }
}

// MARK: - BLEPeripheral Tests

class BLEPeripheralTests: XCTestCase {
    
    func testPeripheralInitialization() {
        let mockCBPeripheral = MockCBPeripheral()
        let peripheral = BLEPeripheral(cbPeripheral: mockCBPeripheral)
        
        XCTAssertEqual(peripheral.identifier, mockCBPeripheral.identifier)
        XCTAssertEqual(peripheral.name, mockCBPeripheral.name)
        XCTAssertFalse(peripheral.isConnected)
        XCTAssertNotNil(peripheral.cbPeripheral)
    }
    
    func testPeripheralEquality() {
        let mockCBPeripheral1 = MockCBPeripheral()
        let mockCBPeripheral2 = MockCBPeripheral()
        
        let peripheral1 = BLEPeripheral(cbPeripheral: mockCBPeripheral1)
        let peripheral2 = BLEPeripheral(cbPeripheral: mockCBPeripheral1)
        let peripheral3 = BLEPeripheral(cbPeripheral: mockCBPeripheral2)
        
        XCTAssertEqual(peripheral1, peripheral2)
        XCTAssertNotEqual(peripheral1, peripheral3)
    }
    
    func testPeripheralHashing() {
        let mockCBPeripheral = MockCBPeripheral()
        let peripheral1 = BLEPeripheral(cbPeripheral: mockCBPeripheral)
        let peripheral2 = BLEPeripheral(cbPeripheral: mockCBPeripheral)
        
        XCTAssertEqual(peripheral1.hashValue, peripheral2.hashValue)
    }
    
    func testConnectionStateChange() {
        let mockCBPeripheral = MockCBPeripheral()
        let peripheral = BLEPeripheral(cbPeripheral: mockCBPeripheral)
        
        XCTAssertFalse(peripheral.isConnected)
        
        peripheral.isConnected = true
        XCTAssertTrue(peripheral.isConnected)
        
        peripheral.isConnected = false
        XCTAssertFalse(peripheral.isConnected)
    }
}
