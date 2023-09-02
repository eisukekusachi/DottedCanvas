//
//  DocumentsFolderView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import SwiftUI

struct DocumentsFolderView: View {
    @Binding var fileDataArray: [DocumentsFolderFileData]

    var diameter: CGFloat = 44

    var body: some View {
        List {
            ForEach(fileDataArray) { data in
                HStack {
                    Image(uiImage: data.thumbnail ?? UIImage.checkered(with: CGSize(width: diameter, height: diameter)))
                        .resizable()
                        .frame(width: diameter, height: diameter)
                    Text("\(data.title)")
                }
            }
        }
    }
}

struct DocumentsFolderView_Previews: PreviewProvider {
    static var previews: some View {
        @State var dotImageDataArray: [DocumentsFolderFileData] = []
        DocumentsFolderView(fileDataArray: $dotImageDataArray)
    }
}
