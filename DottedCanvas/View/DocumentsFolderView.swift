//
//  DocumentsFolderView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import SwiftUI

struct DocumentsFolderView: View {

    @Binding var isViewPresented: Bool
    @ObservedObject var viewModel: DocumentsFolderFileViewModel
    var completion: ((String) -> Void)?

    var diameter: CGFloat = 44

    var body: some View {
        List {
            ForEach(viewModel.fileDataArray.reversed()) { data in
                HStack {
                    Image(uiImage: data.thumbnail ?? UIImage.checkered(with: CGSize(width: diameter, height: diameter)))
                        .resizable()
                        .frame(width: diameter, height: diameter)
                    Text("\(data.title)")
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    completion?(data.title)
                    isViewPresented = false
                }
            }
        }
        .onAppear {
            viewModel.fileDataArray.sort {
                $0.latestUpdateDate < $1.latestUpdateDate
            }
        }
    }
}

struct DocumentsFolderView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isViewPresented: Bool = true
        DocumentsFolderView(isViewPresented: $isViewPresented,
                            viewModel: DocumentsFolderFileViewModel())
    }
}
