import SwiftUI

struct ContentView: View {
    @State private var peripherals: [BLEPeripheral] = []
    @State private var isConnected: Bool = false
    private let bleMiddleware = BLEMiddleware()

    var body: some View {
        VStack {
            Text("BLE Peripherals")
                .font(.largeTitle)
                .padding()

            List(peripherals, id: \.identifier) { peripheral in
                HStack {
                    Text(peripheral.name ?? "Unknown")
                    Spacer()
                    if peripheral.isConnected {
                        Text("Connected")
                            .foregroundColor(.green)
                    } else {
                        Button("Connect") {
                            connectToPeripheral(peripheral)
                        }
                    }
                }
            }

            Button("Discover Peripherals") {
                discoverPeripherals()
            }
            .padding()
        }
        .onAppear {
            discoverPeripherals()
        }
    }

    private func discoverPeripherals() {
        bleMiddleware.discoverPeripherals { discoveredPeripherals in
            self.peripherals = discoveredPeripherals
        }
    }

    private func connectToPeripheral(_ peripheral: BLEPeripheral) {
        bleMiddleware.connectToPeripheral(peripheral: peripheral) { success in
            if success {
                if let index = peripherals.firstIndex(where: { $0.identifier == peripheral.identifier }) {
                    peripherals[index].isConnected = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}