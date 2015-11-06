import CoreBluetooth
import BluetoothKit

// A Receiver of location information
class LocationReceiver: BKCentralDelegate {
    
    let central = BKCentral()
    var discoveries = [BKDiscovery]()
    
    deinit {
        try! central.stop()
    }
    
    func stop() {
        try! central.stop()
    }
    
    func startCentral() {
        do {
            central.delegate = self
            
            let configuration = BKConfiguration(
                dataServiceUUID: LocationServiceConstants.serviceUUID,
                dataServiceCharacteristicUUID: LocationServiceConstants.characteristicUUID
            )
            
            try central.startWithConfiguration(configuration)
        } catch let error {
            print("Error while starting: \(error)")
        }
    }
    
    func scan(foundNewDiscovery: ([BKDiscovery]) -> Void) {
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            // indexPathsToRemove
            let _ = changes.filter({ $0 == .Remove(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            self.discoveries = discoveries
            // indexPathsToInsert
            let _ = changes.filter({ $0 == .Insert(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            for insertedDiscovery in changes.filter({ $0 == .Insert(discovery: nil) }) {
                print("Discovery: \(insertedDiscovery)")
            }
            
            if (discoveries.count > 0) {
                foundNewDiscovery(self.discoveries)
            }
        }, stateHandler: { newState in
        }, errorHandler: { error in
            print("Error from scanning: \(error)")
        })
    }
    
    internal func central(central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        print("Remote peripheral did disconnect: \(remotePeripheral)")
    }
    
}
