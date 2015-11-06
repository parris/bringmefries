import CoreBluetooth
import BluetoothKit

// A Provider of location information
class LocationProvider: BKPeripheralDelegate {
    
    private let peripheral = BKPeripheral()
    
    deinit {
        try! peripheral.stop()
    }
    
    private func startPeripheral() {
        
        peripheral.delegate = self
        
        do {
            // The name of this peripheral is the current device
            let localName = UIDevice.currentDevice().name
            
            let configuration = BKPeripheralConfiguration(
                dataServiceUUID: LocationServiceConstants.serviceUUID,
                dataServiceCharacteristicUUID: LocationServiceConstants.characteristicUUID,
                localName: localName
            )
            
            try peripheral.startWithConfiguration(configuration)
            // Handle incoming connections
        } catch let error {
            print(error)
        }
    }
    
    @objc private func sendData() {
        // TODO: Get real lat lon
        let latlon:String = "-122.40482069999997,37.782403699999996"
        let data:NSData = latlon.dataUsingEncoding(NSUTF8StringEncoding)!
        
        for remoteCentral in peripheral.connectedRemoteCentrals {
            peripheral.sendData(data, toRemoteCentral: remoteCentral) { data, remoteCentral, error in
                guard error == nil else {
                    return
                }
            }
        }
    }
    
    internal func peripheral(peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
    }
    
    
    internal func peripheral(peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
    }
}
