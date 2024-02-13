//
//  ContentView.swift
//  FitBuddy
//
//  Created by Sachin on 2023-12-28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ARViewContainer()
            .ignoresSafeArea(.all )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
