//
//  ContentView.swift
//  Sanpo
//
//  Created by Riomar on 2025/08/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CompassDotsView() // <- this is the actual compass
            .ignoresSafeArea()
            .ignoresSafeArea(.all, edges: .bottom)
            .statusBarHidden()
            .persistentSystemOverlays(.hidden)
    }
}

#Preview {
    ContentView()
}
