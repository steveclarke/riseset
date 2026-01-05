import Foundation
import CoreLocation
import Combine

@MainActor
final class SunTimesModel: ObservableObject {
    @Published var sunTimes: SunTimes?
    @Published var locationName: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = true

    private let locationService = LocationService()
    private let sunCalculator = SunCalculator()
    private var cancellables = Set<AnyCancellable>()
    private var midnightTimer: Timer?

    var sunriseFormatted: String {
        sunTimes?.sunriseFormatted ?? "--:--"
    }

    var sunsetFormatted: String {
        sunTimes?.sunsetFormatted ?? "--:--"
    }

    var isDaytime: Bool {
        sunTimes?.isDaytime ?? true
    }

    init() {
        setupBindings()
        scheduleMidnightUpdate()
        locationService.requestAuthorization()
    }

    private func setupBindings() {
        locationService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                self?.calculateSunTimes(for: coordinate)
            }
            .store(in: &cancellables)

        locationService.$locationName
            .assign(to: &$locationName)

        locationService.$errorMessage
            .sink { [weak self] error in
                self?.errorMessage = error
                if error != nil {
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)
    }

    private func scheduleMidnightUpdate() {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
              let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 5, of: tomorrow)
        else { return }

        let timeInterval = midnight.timeIntervalSinceNow

        midnightTimer?.invalidate()
        midnightTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
                self?.scheduleMidnightUpdate()
            }
        }
    }

    private func calculateSunTimes(for coordinate: CLLocationCoordinate2D) {
        if let times = sunCalculator.calculate(for: coordinate) {
            sunTimes = times
            errorMessage = nil
        } else {
            errorMessage = "Unable to calculate sun times for this location."
        }
        isLoading = false
    }

    func refresh() {
        isLoading = true
        locationService.requestLocation()
    }
}
