//
//  ViewController.swift
//  BLEApp
//
//  Created by antonio on 2025/9/25.
//

import UIKit
import BLEMiddleware
import CoreBluetooth

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let bleMiddleware = BLEMiddleware()
    private var statusLabel: UILabel!
    private var scanButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bleMiddleware.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "BLE Scanner"
        
        // Status label
        statusLabel = UILabel()
        statusLabel.text = "Bluetooth Status: Unknown"
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Scan button
        scanButton = UIButton(type: .system)
        scanButton.setTitle("Start Scanning", for: .normal)
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanButton)
        
        // Table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scanButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc private func scanButtonTapped() {
        if scanButton.titleLabel?.text == "Start Scanning" {
            bleMiddleware.discoverPeripherals()
            scanButton.setTitle("Stop Scanning", for: .normal)
        } else {
            bleMiddleware.stopDiscovery()
            scanButton.setTitle("Start Scanning", for: .normal)
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleMiddleware.discoveredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BLETableViewCell.identifier, for: indexPath) as? BLETableViewCell else {
            return UITableViewCell()
        }
        let peripheral = bleMiddleware.discoveredPeripherals[indexPath.row]
        var jsonString = ""
        if let originalDict = peripheral.manufactureData {
            jsonString = originalDict.map { String(format: "%02X", $0) }.joined(separator: " ")
        }
        cell.nameLabel.text = peripheral.name ?? "Unknown Device"
        cell.idLabel.text = peripheral.identifier.uuidString
        cell.advLabel.text = jsonString
        cell.connectButtonClickClosure = { [weak self]  in
            guard let self = self else {return}
            if peripheral.isConnected {
                self.bleMiddleware.disconnectFromPeripheral(peripheral)
            } else {
                self.bleMiddleware.connectToPeripheral(peripheral)
            }
        }
        if peripheral.isConnected {
            cell.connectButton.setTitle("Disconnect", for: .normal)
        }else {
            cell.connectButton.setTitle("Connect", for: .normal)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - BLEMiddlewareDelegate
extension ViewController: BLEMiddlewareDelegate {
    func bleMiddleware(_ middleware: BLEMiddleware, didUpdateState state: CBManagerState) {
        DispatchQueue.main.async {
            switch state {
            case .poweredOn:
                self.statusLabel.text = "Bluetooth Status: Powered On"
                self.scanButton.isEnabled = true
            case .poweredOff:
                self.statusLabel.text = "Bluetooth Status: Powered Off"
                self.scanButton.isEnabled = false
            case .unauthorized:
                self.statusLabel.text = "Bluetooth Status: Unauthorized"
                self.scanButton.isEnabled = false
            case .unsupported:
                self.statusLabel.text = "Bluetooth Status: Unsupported"
                self.scanButton.isEnabled = false
            default:
                self.statusLabel.text = "Bluetooth Status: Unknown"
                self.scanButton.isEnabled = false
            }
        }
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDiscoverPeripheral peripheral: BLEPeripheral) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didConnectPeripheral peripheral: BLEPeripheral) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func bleMiddleware(_ middleware: BLEMiddleware, didDisconnectPeripheral peripheral: BLEPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
