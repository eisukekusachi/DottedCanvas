//
//  MainImagePreviewView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct MainImagePreviewView: View {

    @Binding var mainImage: UIImage?
    let diameter: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: diameter, height: diameter)

            Image(uiImage: mainImage ?? UIImage.checkered(with: CGSize(width: 500, height: 500)))
                .resizable()
                .frame(width: diameter, height: diameter)
                .overlay(
                    Rectangle()
                        .strokeBorder(Color(uiColor: .init(white: 0.9, alpha: 1.0)),
                                      lineWidth: 1)
                )
        }
    }
}

struct MainImagePreviewView_Previews: PreviewProvider {
    static var previews: some View {

        @ObservedObject var viewModel = DotImageViewModel()
        MainImagePreviewView(mainImage: $viewModel.mainImage,
                             diameter: 200)
    }
}
