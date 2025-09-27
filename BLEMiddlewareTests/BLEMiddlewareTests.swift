//
//  BLEMiddlewareTests.swift
//  BLEMiddlewareTests
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
    
    func testStateUpdate() {
        let mockCentralManager = MockCBCentralManager()
        mockCentralManager.mockState = .poweredOn
        middleware.centralManagerDidUpdateState(mockCentralManager)
        XCTAssertTrue(mockDelegate.didUpdateStateCalled)
    }
    
    func testStateUpdateWithDifferentStates() {
        let mockCentralManager = MockCBCentralManager()
        
        // Test poweredOff state
        mockCentralManager.mockState = .poweredOff
        middleware.centralManagerDidUpdateState(mockCentralManager)
        XCTAssertTrue(mockDelegate.didUpdateStateCalled)
        
        // Reset and test unauthorized state
        mockDelegate.didUpdateStateCalled = false
        mockCentralManager.mockState = .unauthorized
        middleware.centralManagerDidUpdateState(mockCentralManager)
        XCTAssertTrue(mockDelegate.didUpdateStateCalled)
    }
    
    func testDelegateNilHandling() {
        middleware.delegate = nil
        let mockCentralManager = MockCBCentralManager()
        
        // Should not crash when delegate is nil
        XCTAssertNoThrow({
            self.middleware.centralManagerDidUpdateState(mockCentralManager)
        })
    }
    
    func testDiscoverPeripheralsMethod() {
        // Test that discoverPeripherals method exists and can be called
        XCTAssertNoThrow({
            self.middleware.discoverPeripherals()
        })
    }
    
    func testStopDiscoveryMethod() {
        // Test that stopDiscovery method exists and can be called
        XCTAssertNoThrow({
            self.middleware.stopDiscovery()
        })
    }
    
    func testPerformanceOfMiddlewareInitialization() {
        measure {
            for _ in 0..<100 {
                let testMiddleware = BLEMiddleware()
                _ = testMiddleware.discoveredPeripherals
                _ = testMiddleware.connectedPeripherals
            }
        }
    }
}

// MARK: - Mock Classes

class MockBLEMiddlewareDelegate: BLEMiddlewareDelegate {
    var didUpdateStateCalled = false
    var didDiscoverPeripheralCalled = false
    var didConnectPeripheralCalled = false
    var didDisconnectPeripheralCalled = false
    
    var lastState: CBManagerState?
    var lastDiscoveredPeripheral: BLEPeripheral?
    var lastConnectedPeripheral: BLEPeripheral?
    var lastDisconnectedPeripheral: BLEPeripheral?
    var lastError: Error?
    
    func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState) {
        didUpdateStateCalled = true
        lastState = state
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
        didDiscoverPeripheralCalled = true
        lastDiscoveredPeripheral = peripheral
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didConnectPeripheral peripheral: BLEPeripheral) {
        didConnectPeripheralCalled = true
        lastConnectedPeripheral = peripheral
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDisconnectPeripheral peripheral: BLEPeripheral, error: Error?) {
        didDisconnectPeripheralCalled = true
        lastDisconnectedPeripheral = peripheral
        lastError = error
    }
    
    func reset() {
        didUpdateStateCalled = false
        didDiscoverPeripheralCalled = false
        didConnectPeripheralCalled = false
        didDisconnectPeripheralCalled = false
        lastState = nil
        lastDiscoveredPeripheral = nil
        lastConnectedPeripheral = nil
        lastDisconnectedPeripheral = nil
        lastError = nil
    }
}

class MockCBCentralManager: CBCentralManager {
    var mockState: CBManagerState = .poweredOn
    var scanStarted = false
    var scanStopped = false
    
    override var state: CBManagerState {
        return mockState
    }
    
    override func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?) {
        scanStarted = true
    }
    
    override func stopScan() {
        scanStopped = true
    }
}

// Test helper class that mimics BLEPeripheral behavior
class TestBLEPeripheral {
    let identifier: UUID
    var isConnected: Bool = false
    var manufactureData: Data?
    var cbPeripheral: CBPeripheral? = nil
    var name: String? = nil
    
    init(identifier: UUID, name: String? = nil) {
        self.identifier = identifier
        self.name = name
    }
}

// Make TestBLEPeripheral conform to Equatable and Hashable like BLEPeripheral
extension TestBLEPeripheral: Equatable {
    static func == (lhs: TestBLEPeripheral, rhs: TestBLEPeripheral) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension TestBLEPeripheral: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: - BLEPeripheral Tests

class BLEPeripheralTests: XCTestCase {
    
    func testBLEPeripheralIdentifier() {
        let testId = UUID()
        let testPeripheral = TestBLEPeripheral(identifier: testId)
        
        XCTAssertEqual(testPeripheral.identifier, testId)
    }
    
    func testBLEPeripheralConnectionState() {
        let testPeripheral = TestBLEPeripheral(identifier: UUID())
        
        // Initial state should be disconnected
        XCTAssertFalse(testPeripheral.isConnected)
        
        // Test state change
        testPeripheral.isConnected = true
        XCTAssertTrue(testPeripheral.isConnected)
        
        testPeripheral.isConnected = false
        XCTAssertFalse(testPeripheral.isConnected)
    }
    
    func testBLEPeripheralEquality() {
        let id1 = UUID()
        let id2 = UUID()
        
        let peripheral1 = TestBLEPeripheral(identifier: id1)
        let peripheral2 = TestBLEPeripheral(identifier: id1)
        let peripheral3 = TestBLEPeripheral(identifier: id2)
        
        XCTAssertEqual(peripheral1, peripheral2)
        XCTAssertNotEqual(peripheral1, peripheral3)
    }
    
    func testBLEPeripheralHashing() {
        let id = UUID()
        let peripheral1 = TestBLEPeripheral(identifier: id)
        let peripheral2 = TestBLEPeripheral(identifier: id)
        
        XCTAssertEqual(peripheral1.hashValue, peripheral2.hashValue)
    }
    
    func testBLEPeripheralManufactureData() {
        let testPeripheral = TestBLEPeripheral(identifier: UUID())
        let testData = Data([0x01, 0x02, 0x03])
        
        // Initial state should be nil
        XCTAssertNil(testPeripheral.manufactureData)
        
        // Test setting manufacture data
        testPeripheral.manufactureData = testData
        XCTAssertEqual(testPeripheral.manufactureData, testData)
    }
}
