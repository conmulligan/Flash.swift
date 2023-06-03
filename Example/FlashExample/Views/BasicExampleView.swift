//
//  BasicExampleView.swift
//  FlashExample
//
//  Created by Conor Mulligan on 28/05/2023.
//

import SwiftUI
import Flash

struct BasicExampleView: View {
    private func showFlash() {
        let flash = FlashView(text: "Hello!",
                              image: UIImage(systemName: "star.fill"))
        flash.accessibilityIdentifier = "flash_view"
        flash.show(duration: 5)
    }

    var body: some View {
        Button("Show Flash") {
            showFlash()
        }
        .accessibilityIdentifier("show_basic_flash_view_button")
    }
}

struct ButtonExample_Previews: PreviewProvider {
    static var previews: some View {
        BasicExampleView()
    }
}
