import SwiftUI

struct MenuBarLabel: View {
    @EnvironmentObject var model: SunTimesModel

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: model.nextEventIcon)
                .symbolRenderingMode(.multicolor)
            Text(model.nextEventTime)
        }
    }
}
