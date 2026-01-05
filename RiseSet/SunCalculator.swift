import Foundation
import CoreLocation
import Solar

struct SunTimes {
    let sunrise: Date?
    let sunset: Date?
    let isDaytime: Bool

    var sunriseFormatted: String {
        formatTime(sunrise)
    }

    var sunsetFormatted: String {
        formatTime(sunset)
    }

    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "--:--" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

struct SunCalculator {
    func calculate(for coordinate: CLLocationCoordinate2D, date: Date = Date()) -> SunTimes? {
        guard let solar = Solar(for: date, coordinate: coordinate) else {
            return nil
        }

        return SunTimes(
            sunrise: solar.sunrise,
            sunset: solar.sunset,
            isDaytime: solar.isDaytime
        )
    }
}
