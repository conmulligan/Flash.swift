//
//  FlashExampleView.swift
//  FlashExample
//
//  Created by Conor Mulligan on 14/05/2023.
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
import Flash

struct FlashExampleView: View {

    @State private var text: String = "Sample flash text!"

    let symbolNames = [
        "star.fill",
        "trash.fill",
        "folder.fill"
    ]
    
    @State var symbolName = "star.fill"
    
    @State private var configuration = FlashView.Configuration.default

    private var foregroundColor: Binding<Color> {
        Binding(
            get: { Color(configuration.foregroundColor) },
            set: { configuration.foregroundColor = UIColor($0) }
        )
    }
    
    private var backgroundColor: Binding<Color> {
        Binding(
            get: { Color(configuration.backgroundColor) },
            set: { configuration.backgroundColor = UIColor($0) }
        )
    }
    
    @State private var textColor = Color(uiColor: .white)

    // MARK: - Actions
    
    private func reset() {
        configuration = .default
        text = "Sample flash text!"
        symbolName = "star.fill"
    }
    
    private func showFlash() {
        let image = UIImage(systemName: symbolName)?.withRenderingMode(.alwaysTemplate)
        let flash = FlashView(text: text, image: image, configuration: configuration)
        flash.show()
    }
    
    // MARK: - Rendering
    
    var body: some View {
        Form {
            Section("Content") {
                TextField("Text", text: $text)
                SymbolPicker(symbolNames: symbolNames, selected: $symbolName)
            }
            
            Section("Appearance") {
                ColorPicker("Text Color", selection: foregroundColor)
                ColorPicker("Background Color", selection: backgroundColor)
                VStack {
                    HStack {
                        Text("Corner Radius")
                        Spacer()
                        Text("\(configuration.cornerRadius, specifier: "%.0f")")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $configuration.cornerRadius, in: 0...100)
                }
            }
            
            Section("Layout") {
                Picker("Alignment", selection: $configuration.alignment) {
                    Text("Top").tag(FlashView.Alignment.top)
                    Text("Bottom").tag(FlashView.Alignment.bottom)
                }
                
                HStack {
                    Text("Image-text spacing")
                    Spacer()
                    TextField("0", value: $configuration.spacing, formatter: NumberFormatter())
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Edge Insets")
                    EdgeInsetsView(edgeInsets: $configuration.insets)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Content Insets")
                    EdgeInsetsView(edgeInsets: $configuration.contentInsets)
                }
            }
            Section("Haptics") {
                Toggle("Plays Haptics", isOn: $configuration.playsHaptics)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Flash Example")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Reset") {
                    reset()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Show") {
                    showFlash()
                }
                .bold()
            }
        }
    }
}

struct FlashExampleView_Previews: PreviewProvider {
    static var previews: some View {
        FlashExampleView()
    }
}
