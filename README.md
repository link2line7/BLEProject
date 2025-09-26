# BLE Project

## Overview
The BLE Project is a Swift-based application that demonstrates the use of a middleware framework for discovering, connecting, and disconnecting from Bluetooth Low Energy (BLE) peripherals. The project consists of a BLE middleware framework and an iOS application built with UIKit that utilizes this middleware.

## Project Structure

### BLEMiddleware Framework
A comprehensive framework providing core BLE functionality:

- **BLEMiddleware.swift**: Main middleware class with delegate-based API for BLE operations
- **BLEPeripheral.swift**: Wrapper class for BLE peripherals with connection state management
- **BLEMiddlewareDelegate**: Protocol for receiving BLE events and state changes

### BLEApp (iOS Application)
A UIKit-based iOS application demonstrating the middleware:

- **AppDelegate.swift**: Application lifecycle management
- **SceneDelegate.swift**: Scene-based UI management
- **ViewController.swift**: Main UI controller with table view for peripheral management

### Testing Suite
Comprehensive unit tests achieving >50% code coverage:

- **BLEMiddlewareTests.swift**: Tests for middleware functionality with mock objects
- Covers peripheral discovery, connection management, and delegate callbacks

### Documentation
Full DocC documentation including:

- **BLEMiddleware.md**: Framework overview and getting started guide
- **DiscoveringPeripherals.md**: Detailed peripheral discovery documentation
- **ConnectingToPeripherals.md**: Connection establishment guide
- **ManagingConnections.md**: Connection lifecycle and best practices

## Setup Instructions
1. Open `BLEProject.xcodeproj` in Xcode
2. Select the BLEApp scheme
3. Build the project (⌘+B)
4. Run on a physical iOS device with Bluetooth capabilities (required for BLE functionality)

## Key Features
- **Simple API**: Easy-to-use methods for BLE operations
- **Delegate Pattern**: Event-driven architecture for BLE callbacks
- **UIKit Interface**: Native iOS table view for peripheral management
- **Comprehensive Testing**: Unit tests with mock objects
- **Full Documentation**: DocC-formatted API documentation
- **iOS 17+ Compatible**: Built for current iOS versions

## Usage Example
```swift
import BLEMiddleware

class MyViewController: UIViewController, BLEMiddlewareDelegate {
    let bleMiddleware = BLEMiddleware()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bleMiddleware.delegate = self
        bleMiddleware.discoverPeripherals()
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
        print("Discovered: \(peripheral.name ?? "Unknown")")
    }
}
```

## Requirements
- Xcode 15.0+
- iOS 17.0+
- Physical iOS device with Bluetooth LE support
- Swift 5.0+

## Architecture
The project follows a clean architecture pattern:
- **Framework Layer**: BLEMiddleware provides the core BLE abstraction
- **Application Layer**: UIKit app demonstrates framework usage
- **Testing Layer**: Comprehensive unit tests ensure reliability
- **Documentation Layer**: DocC provides API documentation

## License
This project is licensed under the MIT License. See the LICENSE file for more details.
