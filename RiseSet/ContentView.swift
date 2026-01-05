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

            Divider()

            HStack {
                Button("Refresh") {
                    model.refresh()
                }

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
        }
        .padding()
        .frame(width: 220)
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
                icon: "sunrise.fill",
                label: "Sunrise",
                time: model.sunriseFormatted
            )

            SunTimeRow(
                icon: "sunset.fill",
                label: "Sunset",
                time: model.sunsetFormatted
            )
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

            Button("Open System Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
                    NSWorkspace.shared.open(url)
                }
            }
            .font(.caption)
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
