//
//  SubImagePreviewView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct SubImagePreviewView: View {

    @EnvironmentObject var data: DotImageCreationData
    let viewSize: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: viewSize, height: viewSize)

            Image(uiImage: data.dotImage)
                .resizable()
                .frame(width: viewSize, height: viewSize)
                .overlay(
                    Rectangle()
                        .strokeBorder(Color(uiColor: .init(white: 0.9, alpha: 1.0)),
                                      lineWidth: 1)
                )
        }
    }
}

struct SubImagePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        @State var data = DotImageCreationData()

        SubImagePreviewView(viewSize: 300.0)
            .environmentObject(data)
    }
}
