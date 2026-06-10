import CoreLocation
import Observation

@Observable
final class HeadingService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var currentHeading: Double?

    override init() {
        super.init()
        manager.delegate = self
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return }
        MainActor.assumeIsolated { currentHeading = newHeading.magneticHeading }
    }
}
