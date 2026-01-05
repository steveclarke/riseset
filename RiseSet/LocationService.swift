import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationTimeout: Task<Void, Never>?

    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var locationName: String?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    @Published var isPermissionError: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = locationManager.authorizationStatus
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        errorMessage = nil
        isPermissionError = false
        locationTimeout?.cancel()
        locationManager.requestLocation()

        // Timeout after 30 seconds
        locationTimeout = Task {
            try? await Task.sleep(for: .seconds(30))
            if !Task.isCancelled && currentLocation == nil && errorMessage == nil {
                errorMessage = "Location request timed out. Please try again."
            }
        }
    }

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            Task { @MainActor in
                if let placemark = placemarks?.first {
                    self?.locationName = placemark.locality ?? placemark.administrativeArea ?? "Unknown"
                } else {
                    // Fallback to coordinates if geocoding fails
                    let lat = String(format: "%.2f", location.coordinate.latitude)
                    let lon = String(format: "%.2f", location.coordinate.longitude)
                    self?.locationName = "\(lat), \(lon)"
                }
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus

            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                requestLocation()
            case .denied:
                isPermissionError = true
                errorMessage = "Location access denied. Enable in System Settings > Privacy & Security > Location Services."
            case .restricted:
                isPermissionError = true
                errorMessage = "Location access is restricted on this device."
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            locationTimeout?.cancel()
            currentLocation = location.coordinate
            reverseGeocode(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationTimeout?.cancel()
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    isPermissionError = true
                    errorMessage = "Location access denied."
                case .locationUnknown:
                    errorMessage = "Unable to determine location. Please try again."
                default:
                    errorMessage = "Location error: \(error.localizedDescription)"
                }
            } else {
                errorMessage = "Location error: \(error.localizedDescription)"
            }
        }
    }
}
