//
//  ContentView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var dotImageViewModel = DotImageViewModel()

    var body: some View {
        DottedCanvasView(viewModel: dotImageViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
