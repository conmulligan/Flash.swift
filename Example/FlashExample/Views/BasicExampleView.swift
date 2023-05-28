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
        flash.show()
    }

    var body: some View {
        Button("Show Flash") {
            showFlash()
        }
    }
}

struct ButtonExample_Previews: PreviewProvider {
    static var previews: some View {
        BasicExampleView()
    }
}
