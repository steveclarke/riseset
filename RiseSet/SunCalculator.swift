import Foundation
import CoreLocation
import Solar

enum ForecastConfig {
    static let dayCount = 7
}

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

    private static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
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

    var sunriseShort: String {
        if isPolarDay { return "—" }
        if isPolarNight { return "—" }
        return formatShortTime(sunrise)
    }

    var sunsetShort: String {
        if isPolarDay { return "—" }
        if isPolarNight { return "—" }
        return formatShortTime(sunset)
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

    var dayLengthFormatted: String {
        if isPolarDay { return "24h 0m" }
        if isPolarNight { return "0h 0m" }
        guard let sunrise = sunrise, let sunset = sunset else { return "—" }
        let seconds = Int(sunset.timeIntervalSince(sunrise))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "--:--" }
        return Self.timeFormatter.string(from: date)
    }

    private func formatShortTime(_ date: Date?) -> String {
        guard let date = date else { return "--:--" }
        return Self.shortTimeFormatter.string(from: date)
    }
}

struct DayForecast: Identifiable {
    let id = UUID()
    let date: Date
    let sunTimes: SunTimes

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    var dayName: String {
        Self.dayFormatter.string(from: date)
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

    func calculateForecast(for coordinate: CLLocationCoordinate2D, days: Int = ForecastConfig.dayCount) -> [DayForecast] {
        let calendar = Calendar.current
        var forecasts: [DayForecast] = []

        for dayOffset in 1...days {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()),
                  let times = calculate(for: coordinate, date: date) else {
                continue
            }
            forecasts.append(DayForecast(date: date, sunTimes: times))
        }
        return forecasts
    }
}
