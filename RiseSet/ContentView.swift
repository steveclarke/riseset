import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: SunTimesModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let error = model.errorMessage {
                errorView(message: error)
            } else if model.isLoading {
                loadingView
            } else {
                sunTimesView
            }

        }
        .padding()
        .fixedSize()
    }

    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.7)
            Text("Getting location...")
                .foregroundStyle(.secondary)
        }
    }

    private var sunTimesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let location = model.locationName {
                Text(location)
                    .font(.headline)
            }

            SunTimeRow(
                icon: "sun.horizon.fill",
                label: "First Light",
                time: model.civilDawnFormatted
            )

            SunTimeRow(
                icon: "sunrise.fill",
                label: "Sunrise",
                time: model.sunriseFormatted
            )

            SunTimeRow(
                icon: "sunset.fill",
                label: "Sunset",
                time: model.sunsetFormatted
            )

            SunTimeRow(
                icon: "sun.horizon.fill",
                label: "Last Light",
                time: model.civilDuskFormatted
            )

            if !model.forecast.isEmpty {
                ForecastSection(forecast: model.forecast)
            }
        }
    }

    private func errorView(message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "location.slash")
                    .foregroundStyle(.secondary)
                Text("Location Unavailable")
                    .font(.headline)
            }

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)

            if model.isPermissionError {
                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .font(.caption)
            }
        }
    }
}

struct SunTimeRow: View {
    let icon: String
    let label: String
    let time: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)

            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(time)
                .fontWeight(.medium)
                .monospacedDigit()
        }
    }
}

struct ForecastSection: View {
    let forecast: [DayForecast]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .frame(width: 12)
                    Text("Next \(ForecastConfig.dayCount) days")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.top, 8)

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(forecast) { day in
                        ForecastRow(day: day)
                    }
                }
                .padding(.top, 8)
                .transition(.opacity)
            }
        }
    }
}

struct ForecastRow: View {
    let day: DayForecast

    var body: some View {
        HStack {
            Text(day.dayName)
                .frame(width: 36, alignment: .leading)
                .foregroundStyle(.secondary)
            Spacer()
            Image(systemName: "sunrise.fill")
                .symbolRenderingMode(.multicolor)
                .font(.caption)
            Text(day.sunTimes.sunriseFormatted)
                .monospacedDigit()
                .font(.callout)
            Spacer().frame(width: 16)
            Image(systemName: "sunset.fill")
                .symbolRenderingMode(.multicolor)
                .font(.caption)
            Text(day.sunTimes.sunsetFormatted)
                .monospacedDigit()
                .font(.callout)
        }
        .font(.callout)
    }
}
