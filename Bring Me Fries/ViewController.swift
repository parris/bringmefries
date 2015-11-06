import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var lm: CLLocationManager!
    var imageView: UIImageView!
    var heading: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: UIImage (named: "arrow.png"))
        imageView.center = view.center
        view.addSubview(imageView)
        
        lm = CLLocationManager()
        lm.delegate = self
        lm.startUpdatingHeading()
    }
    
    override func viewWillAppear(animated: Bool) {
        imageView.alpha = 0.0
        imageView.transform = CGAffineTransformIdentity
    }
    
    func imageFadeIn(imageView: UIImageView, heading: CGFloat) {
        UIView.animateWithDuration(1.0, delay: 1.0, options: .CurveEaseOut, animations: {
            imageView.alpha = 1.0
            imageView.transform = CGAffineTransformMakeRotation(heading)
            }, completion: nil
        )}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // heading is in radians from north
        heading = CGFloat(newHeading.magneticHeading) * CGFloat(M_PI) / CGFloat(180.0)
        imageFadeIn(imageView, heading: heading)
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
