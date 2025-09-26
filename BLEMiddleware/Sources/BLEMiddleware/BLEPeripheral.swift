class BLEPeripheral {
    var identifier: UUID
    var name: String?
    var isConnected: Bool

    init(identifier: UUID, name: String? = nil) {
        self.identifier = identifier
        self.name = name
        self.isConnected = false
    }

    func connect() {
        isConnected = true
    }

    func disconnect() {
        isConnected = false
    }
}