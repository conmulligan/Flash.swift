//
//  SymbolPicker.swift
//  FlashExample
//
//  Created by Conor Mulligan on 15/05/2023.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import SwiftUI

struct SymbolPicker: View {

    @State var symbolNames: [String]

    @Binding var selected: String?

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                Text("None")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(selected == nil ? Capsule().fill(.tint) : nil)
                    .foregroundColor(selected == nil ? .white : nil)
                    .onTapGesture {
                        selected = nil
                    }
                ForEach(symbolNames, id: \.self) { symbolName in
                    Image(systemName: symbolName)
                        .padding(12)
                        .background(symbolName == selected ? Circle().fill(.tint) : nil)
                        .foregroundColor(symbolName == selected ? .white : nil)
                        .onTapGesture {
                            selected = symbolName
                        }
                }
            }
        }
    }
}

struct SymbolPicker_Previews: PreviewProvider {
    static let names = [
        "star.fill",
        "trash.fill",
        "folder.fill"
    ]

    @State static var selected: String?

    static var previews: some View {
        SymbolPicker(symbolNames: names, selected: $selected)
    }
}
