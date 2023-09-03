//
//  ContentView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var dotImageViewModel = DotImageViewModel()
    @StateObject var documentsFolderFileViewModel = DocumentsFolderFileViewModel()

    var body: some View {
        DottedCanvasView(dotImageViewModel: dotImageViewModel,
                         documentsFolderFileViewModel: documentsFolderFileViewModel)
        .onAppear {
            Task {
                do {
                    try await documentsFolderFileViewModel.appendDocumentsFolderFile()

                } catch {
                    print(error)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
