import SwiftUI

struct MenuBarLabel: View {
    @EnvironmentObject var model: SunTimesModel

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sunrise.fill")
                .symbolRenderingMode(.multicolor)
            Text(model.sunriseFormatted)

            Image(systemName: "sunset.fill")
                .symbolRenderingMode(.multicolor)
            Text(model.sunsetFormatted)
        }
    }
}
