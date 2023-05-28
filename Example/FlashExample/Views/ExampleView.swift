//
//  ExampleView.swift
//  FlashExample
//
//  Created by Conor Mulligan on 28/05/2023.
//

import SwiftUI

struct ExampleView: View {
    var body: some View {
        TabView {
            NavigationStack {
                BasicExampleView()
                    .navigationTitle("Flash")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Basic", systemImage: "bolt.fill")
            }
            NavigationStack {
                AdvancedExampleView()
                    .navigationTitle("Flash")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Advanced", systemImage: "bolt.horizontal.fill")
            }
        }
    }
}

struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}
