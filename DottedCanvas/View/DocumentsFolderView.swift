//
//  DocumentsFolderView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import SwiftUI

struct DocumentsFolderView: View {

    @Binding var isViewPresented: Bool
    @ObservedObject var projectFileList: ProjectFileListViewModel
    var didSelectItem: ((Int) -> Void)?

    var diameter: CGFloat = 44

    var body: some View {
        List {
            ForEach(Array(projectFileList.projects.enumerated().reversed()),
                    id: \.element) { index, data in
                HStack {
                    let checkerdImage = UIImage.checkered(with: CGSize(width: diameter, height: diameter))
                    Image(uiImage: data.thumbnail ?? checkerdImage)
                        .resizable()
                        .frame(width: diameter, height: diameter)
                    Text("\(data.projectName)")
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    didSelectItem?(index)
                    isViewPresented = false
                }
            }
        }
        .onAppear {
            projectFileList.projects.sort {
                $0.latestUpdateDate < $1.latestUpdateDate
            }
        }
    }
}

struct DocumentsFolderView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isViewPresented: Bool = true
        DocumentsFolderView(isViewPresented: $isViewPresented,
                            projectFileList: ProjectFileListViewModel())
    }
}
