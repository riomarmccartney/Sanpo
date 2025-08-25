import CoreLocation
import SwiftUI

class CompassManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var manager = CLLocationManager()
    @Published var heading: Double = 0
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.heading = newHeading.magneticHeading
        }
    }
}
