import UIKit
import CoreLocation
import CoreBluetooth

import BluetoothKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var lm: CLLocationManager!
    var imageView: UIImageView!
    var heading: CGFloat!
    var userLocation: CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: UIImage (named: "arrow.png"))
        imageView.center = view.center
        view.addSubview(imageView)
        
        lm = CLLocationManager()
        lm.delegate = self
    
        //heading
        lm.startUpdatingHeading()
        
        //user location
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestAlwaysAuthorization()
        lm.startUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        imageView.alpha = 0.0
        imageView.transform = CGAffineTransformIdentity
    }
    
    func imageFadeIn(imageView: UIImageView, heading: CGFloat, userLocation: CLLocation) {
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
            imageView.alpha = 1.0
            imageView.transform = CGAffineTransformMakeRotation(heading)
            }, completion: nil
        )}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calcRotateAngle(heading: CGFloat, location1: CLLocation, location2: CLLocation) -> CGFloat {
        let lat1 = location1.coordinate.latitude
        let long1 = location1.coordinate.longitude
        
        let lat2 = location2.coordinate.latitude
        let long2 = location2.coordinate.longitude
        
        let currentHeadingVector: (x: Double, y: Double) = (cos(Double(heading)), sin(Double(heading)))
        let targetHeadingVector: (x: Double, y: Double) = (long2 - long1, lat2 - lat1)
        
        let numerator = currentHeadingVector.x * targetHeadingVector.x + currentHeadingVector.y * targetHeadingVector.y
        let denominator = sqrt(pow(currentHeadingVector.x,2) + pow(currentHeadingVector.y,2)) * sqrt(pow(targetHeadingVector.x,2) + pow(targetHeadingVector.y,2))
        let between_radians = acos(numerator / denominator)
        
        //need to figure out positive/negative
        if currentHeadingVector.x <= targetHeadingVector.x && currentHeadingVector.y <= targetHeadingVector.y {
            return -CGFloat(between_radians)
        }
        return CGFloat(between_radians)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = CGFloat(newHeading.magneticHeading) * CGFloat(M_PI) / CGFloat(180.0)
        if heading != nil && userLocation != nil {
            let location2 = CLLocation(latitude: 50.0, longitude: -122)
            heading = calcRotateAngle(heading, location1: userLocation, location2: location2)
            imageFadeIn(imageView, heading: heading!, userLocation: userLocation!)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
        if heading != nil && userLocation != nil {
            let location2 = CLLocation(latitude: 50.0, longitude: -122)
            heading = calcRotateAngle(heading, location1: userLocation, location2: location2)
            imageFadeIn(imageView, heading: heading!, userLocation: userLocation!)
        }
    }
}

internal protocol RemotePeripheralViewControllerDelegate: class {
    func remotePeripheralViewControllerWillDismiss(remotePeripheralViewController: RemotePeripheralViewController)
}

internal class RemotePeripheralViewController: UIViewController, BKRemotePeripheralDelegate {
    internal weak var delegate: RemotePeripheralViewControllerDelegate?
    internal let remotePeripheral: BKRemotePeripheral
    
    
    internal init(remotePeripheral: BKRemotePeripheral) {
        self.remotePeripheral = remotePeripheral
        super.init(nibName: nil, bundle: nil)
        self.remotePeripheral.delegate = self
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    internal func remotePeripheral(remotePeripheral: BKRemotePeripheral, didUpdateName name: String) {
    }
    
    internal func remotePeripheral(remotePeripheral: BKRemotePeripheral, didSendArbitraryData data: NSData) {
        print("Received data of length: \(data.length) with info: \(data)")
    }
    
}

class ItemViewController: UIViewController, BKAvailabilityObserver, RemotePeripheralViewControllerDelegate, BKRemotePeripheralDelegate {
    
    var locationReceiver = LocationReceiver()
    var locationBroadcaster = LocationProvider()
    internal var remotePeripheral: BKRemotePeripheral?
    
    var isScanning = false
    
    @IBOutlet weak var discoveredDeviceLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationReceiver.central.addAvailabilityObserver(self)
    }
    
    func deviceFound(discoveries: [BKDiscovery]) {
        discoveredDeviceLabel.text = "Found!"
        
        // in reality we'd probably want to connect to all devices not already connected
        self.locationReceiver.central.connect(remotePeripheral: discoveries[0].remotePeripheral) { remotePeripheral, error in
            self.remotePeripheral = remotePeripheral
            remotePeripheral.delegate = self
//            tableView.userInteractionEnabled = true
//            guard error == nil else {
//                print("Error connecting peripheral: \(error)")
//                tableView.deselectRowAtIndexPath(indexPath, animated: true)
//                return
//            }
//            let remotePeripheralViewController = RemotePeripheralViewController(remotePeripheral: remotePeripheral)
//            remotePeripheralViewController.delegate = self
        }
    }
    
    @IBAction func scanTapped(sender: AnyObject) {
        print("Scan")
        if (!isScanning) {
            locationReceiver.startCentral()
        } else {
            locationReceiver.central.interrupScan()
            isScanning = false
            scanButton.setTitle("Scan For a Friend", forState: .Normal)
        }
    }
    
    @IBAction func broadcastTapped(sender: AnyObject) {
        print("Broadcast Existence")
        locationBroadcaster.startPeripheral()
    }
    
    @IBAction func broadcastPositionTapped(sender: AnyObject) {
        print("Broadcast Position")
        locationBroadcaster.sendData()
    }
    
    @IBAction func disconnectTapped(sender: AnyObject) {
        print("Disconnect")
        locationReceiver.stop()
        locationBroadcaster.stop()
    }
    
    internal func availabilityObserver(availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        if availability == .Available {
            locationReceiver.scan(deviceFound)
            isScanning = true
            scanButton.setTitle("Stop Scanning", forState: .Normal)
        } else {
            locationReceiver.central.interrupScan()
        }
    }
    
    internal func availabilityObserver(availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
    }
    
    internal func remotePeripheral(remotePeripheral: BKRemotePeripheral, didUpdateName name: String) {
    }
    
    internal func remotePeripheral(remotePeripheral: BKRemotePeripheral, didSendArbitraryData data: NSData) {
        let str = NSString(data: data, encoding: NSUTF8StringEncoding)
        print("Received data of length: \(data.length) with hash: \(str)")
    }
    
    func remotePeripheralViewControllerWillDismiss(remotePeripheralViewController: RemotePeripheralViewController) {
        do {
            try locationReceiver.central.disconnectRemotePeripheral(remotePeripheralViewController.remotePeripheral)
        } catch let error {
            print("Error disconnecting remote peripheral: \(error)")
        }
    }
}
