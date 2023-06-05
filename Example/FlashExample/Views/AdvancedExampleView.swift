//
//  AdvancedExampleView.swift
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

struct AdvancedExampleView: View {

    @State private var text: String = "Sample flash text!"

    let symbolNames = [
        "star.fill",
        "trash.fill",
        "folder.fill"
    ]

    @State var symbolName: String?

    @State var duration: TimeInterval = 2

    @State private var flashConfig = FlashView.Configuration.defaultConfiguration()

    @State private var animationConfig = DefaultAnimator.Configuration.defaultConfiguration()

    private var imageColor: Binding<Color> {
        Binding(
            get: { Color(flashConfig.imageProperties.tintColor) },
            set: { flashConfig.imageProperties.tintColor = UIColor($0) }
        )
    }

    private var textColor: Binding<Color> {
        Binding(
            get: { Color(flashConfig.titleProperties.textColor) },
            set: { flashConfig.titleProperties.textColor = UIColor($0) }
        )
    }

    private var backgroundColor: Binding<Color> {
        Binding(
            get: { Color(flashConfig.backgroundProperties.color) },
            set: { flashConfig.backgroundProperties.color = UIColor($0) }
        )
    }

    // MARK: - Actions

    private func reset() {
        flashConfig = .defaultConfiguration()
        animationConfig = .defaultConfiguration()
        text = "Sample flash text!"
        symbolName = "star.fill"
    }

    private func showFlash() {
        var image: UIImage?
        if let symbolName {
            image = UIImage(systemName: symbolName)?.withRenderingMode(.alwaysTemplate)
        }
        flashConfig.animator = DefaultAnimator(configuration: animationConfig)
        let flash = FlashView(text: text, image: image, configuration: flashConfig)
        flash.show(duration: duration)
    }

    // MARK: - Rendering

    var body: some View {
        Form {
            Section("Content") {
                TextField("Text", text: $text)
                SymbolPicker(symbolNames: symbolNames, selected: $symbolName)
            }

            Section("Appearance") {
                HStack {
                    Text("Duration (s)")
                    Spacer()
                    TextField("0", value: $duration, formatter: NumberFormatter.decimal)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                }
                ColorPicker("Image Color", selection: imageColor)
                ColorPicker("Text Color", selection: textColor)
                ColorPicker("Background Color", selection: backgroundColor)
                VStack(spacing: 8) {
                    HStack {
                        Text("Corner Radius")
                        Spacer()
                        Text("\(flashConfig.backgroundProperties.cornerRadius, specifier: "%.0f")")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $flashConfig.backgroundProperties.cornerRadius, in: 0...100)
                }
                Stepper(value: $flashConfig.titleProperties.numberOfLines, in: 0...10, step: 1) {
                    HStack {
                        Text("Number of Lines")
                        Spacer()
                        Text("\(flashConfig.titleProperties.numberOfLines)")
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section("Animation") {
                HStack {
                    Text("Duration (s)")
                    Spacer()
                    TextField("0", value: $animationConfig.duration, formatter: NumberFormatter.decimal)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                }
                VStack(spacing: 8) {
                    HStack {
                        Text("Scale Coefficient")
                        Spacer()
                        Text("\(animationConfig.scaleCoefficient, specifier: "%.2f")")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $animationConfig.scaleCoefficient, in: 0...1, step: 0.05)
                }
                VStack(spacing: 8) {
                    HStack {
                        Text("Damping Ratio")
                        Spacer()
                        Text("\(animationConfig.dampingRatio, specifier: "%.2f")")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $animationConfig.dampingRatio, in: 0...1, step: 0.05)
                }
                HStack {
                    Text("Initial Velocity")
                    Spacer()
                    VectorView(vector: $animationConfig.initialVelocity)
                }
            }

            Section("Layout") {
                Toggle("Inset from navigation UI", isOn: $flashConfig.appliesAdditionalInsetsAutomatically)
                Picker("Alignment", selection: $flashConfig.alignment) {
                    Text("Top").tag(FlashView.Configuration.Alignment.top)
                    Text("Bottom").tag(FlashView.Configuration.Alignment.bottom)
                }

                HStack {
                    Text("Image-text spacing")
                    Spacer()
                    TextField("0", value: $flashConfig.spacing, formatter: NumberFormatter.integer)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Edge Insets")
                    EdgeInsetsView(edgeInsets: $flashConfig.insets)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Content Insets")
                    EdgeInsetsView(edgeInsets: $flashConfig.contentInsets)
                }
            }
            Section("Interaction") {
                Toggle("Plays Haptics", isOn: $flashConfig.playsHaptics)
                Toggle("Tap to Dismiss", isOn: $flashConfig.tapToDismiss)
            }
        }
        .scrollDismissesKeyboard(.interactively)
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
        AdvancedExampleView()
    }
}
