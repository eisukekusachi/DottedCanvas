//
//  ProjectListView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/09/02.
//

import SwiftUI

struct ProjectListView: View {

    @Binding var isViewPresented: Bool
    @ObservedObject var viewModel: ProjectListViewModel
    var didSelectItem: ((Int) -> Void)?

    var body: some View {
        List {
            ForEach(Array(viewModel.projects.enumerated().reversed()),
                    id: \.element) { index, data in
                HStack {
                    let imageSize = CGSize(width: 44, height: 44)
                    let checkerdImage = UIImage.checkered(with: imageSize)
                    Image(uiImage: data.thumbnail ?? checkerdImage)
                        .resizable()
                        .frame(width: imageSize.width, height: imageSize.height)
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
            viewModel.projects = viewModel.projects.sorted(by: {
                $0.latestUpdateDate < $1.latestUpdateDate
            })
        }
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isViewPresented: Bool = true
        ProjectListView(isViewPresented: $isViewPresented,
                        viewModel: ProjectListViewModel())
    }
}
