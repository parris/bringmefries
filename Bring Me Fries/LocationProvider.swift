import CoreBluetooth
import BluetoothKit
import CoreLocation

// A Provider of location information
class LocationProvider: UIViewController, BKPeripheralDelegate, CLLocationManagerDelegate {
    
    let peripheral = BKPeripheral()
    
    var lm: CLLocationManager!
    var userLocation: CLLocation!
    
    deinit {
        try! peripheral.stop()
    }
    
    func stop() {
        try! peripheral.stop()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        lm = CLLocationManager()
        lm.delegate = self
        
        //user location
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestAlwaysAuthorization()
        lm.startUpdatingLocation()
        
        userLocation = CLLocation(latitude: -122.40482069999997,longitude: 37.782403699999996)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
    }
    
    func startPeripheral() {
        
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
    
    @objc func sendData() {
        let latlon:String = "\(String(userLocation.coordinate.latitude)),\(String(userLocation.coordinate.longitude))"
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
