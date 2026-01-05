import Foundation
import CoreLocation
import Solar

struct SunTimes {
    let sunrise: Date?
    let sunset: Date?
    let civilDawn: Date?
    let civilDusk: Date?
    let isDaytime: Bool

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    /// True if in polar day (sun never sets)
    var isPolarDay: Bool {
        sunrise == nil && sunset == nil && isDaytime
    }

    /// True if in polar night (sun never rises)
    var isPolarNight: Bool {
        sunrise == nil && sunset == nil && !isDaytime
    }

    var sunriseFormatted: String {
        if isPolarDay { return "Sun up" }
        if isPolarNight { return "No rise" }
        return formatTime(sunrise)
    }

    var sunsetFormatted: String {
        if isPolarDay { return "No set" }
        if isPolarNight { return "Sun down" }
        return formatTime(sunset)
    }

    var civilDawnFormatted: String {
        if isPolarDay { return "—" }
        if isPolarNight { return "—" }
        return formatTime(civilDawn)
    }

    var civilDuskFormatted: String {
        if isPolarDay { return "—" }
        if isPolarNight { return "—" }
        return formatTime(civilDusk)
    }

    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "--:--" }
        return Self.timeFormatter.string(from: date)
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
            civilDawn: solar.civilSunrise,
            civilDusk: solar.civilSunset,
            isDaytime: solar.isDaytime
        )
    }
}
