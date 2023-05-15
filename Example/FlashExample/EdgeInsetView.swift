//
//  EdgeInsetView.swift
//  FlashExample
//
//  Created by Conor Mulligan on 14/05/2023.
//

import SwiftUI

struct EdgeInsetView: View {
    let title: any StringProtocol
    
    @Binding var value: CGFloat
    
    init(_ title: any StringProtocol, value: Binding<CGFloat>) {
        self.title = title
        self._value = value
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("0", value: $value, formatter: NumberFormatter())
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct EdgeInsetView_Previews: PreviewProvider {
    @State static var value: CGFloat = 0
    
    static var previews: some View {
        EdgeInsetView("Edge", value: $value)
    }
}
