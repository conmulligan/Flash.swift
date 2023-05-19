//
//  VectorView.swift
//  FlashExample
//
//  Created by Conor Mulligan on 16/05/2023.
//

import SwiftUI

struct VectorView: View {
    @Binding var vector: CGVector

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                TextField("0", value: $vector.dx, formatter: NumberFormatter.decimal)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                Text("d(x)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80)

            VStack(alignment: .leading, spacing: 0) {
                TextField("0", value: $vector.dy, formatter: NumberFormatter.decimal)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                Text("d(y)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80)
        }
    }
}

struct VectorView_Previews: PreviewProvider {
    @State static var vector: CGVector = .zero

    static var previews: some View {
        VectorView(vector: $vector)
    }
}
