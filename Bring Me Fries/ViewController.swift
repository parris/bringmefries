import UIKit
import CoreLocation

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

class ItemViewController: UIViewController {
    
    var thisDevice = LocationReceiver()
    var remoteDevice = LocationProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func scanTapped(sender: AnyObject) {
        print("Scan")
    }
    
    @IBAction func broadcastTapped(sender: AnyObject) {
        print("Broadcast")
    }
    
    @IBAction func disconnectTapped(sender: AnyObject) {
        print("Disconnect")
    }
}
