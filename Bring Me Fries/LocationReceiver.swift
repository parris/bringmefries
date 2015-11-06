import CoreBluetooth
import BluetoothKit

// A Receiver of location information
class LocationReceiver: BKCentralDelegate, BKAvailabilityObserver {
    
    private let central = BKCentral()
    private var discoveries = [BKDiscovery]()
    
    deinit {
        try! central.stop()
    }
    
    private func startCentral() {
        do {
            central.delegate = self
            central.addAvailabilityObserver(self)
            
            let configuration = BKConfiguration(
                dataServiceUUID: LocationServiceConstants.serviceUUID,
                dataServiceCharacteristicUUID: LocationServiceConstants.characteristicUUID
            )
            
            try central.startWithConfiguration(configuration)
        } catch let error {
            print("Error while starting: \(error)")
        }
    }
    
    private func scan() {
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            // indexPathsToRemove
            let _ = changes.filter({ $0 == .Remove(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            self.discoveries = discoveries
            // indexPathsToInsert
            let _ = changes.filter({ $0 == .Insert(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            for insertedDiscovery in changes.filter({ $0 == .Insert(discovery: nil) }) {
                print("Discovery: \(insertedDiscovery)")
            }
            }, stateHandler: { newState in
            }, errorHandler: { error in
                print("Error from scanning: \(error)")
        })
    }
    
    internal func availabilityObserver(availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        if availability == .Available {
            scan()
        } else {
            central.interrupScan()
        }
    }
    
    internal func availabilityObserver(availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
    }
    
    internal func central(central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        print("Remote peripheral did disconnect: \(remotePeripheral)")
    }
    
}
