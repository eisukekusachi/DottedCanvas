//
//  LoadingDialog.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct LoadingDialog: View {

    @Binding var isVisibleLoadingView: Bool
    @Binding var message: String

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray).opacity(0.08)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(true)

            ZStack {
                Rectangle()
                    .foregroundColor(Color("snackbarBackground"))
                    .cornerRadius(12)

                VStack {
                    ProgressView()

                    Spacer()
                        .frame(height: 4)
                    Text(message)
                        .font(.subheadline)
                }
            }
            .frame(width: 200, height: 100)
        }
        .edgesIgnoringSafeArea(.all)
   }
}

struct LoadingDialog_Previews: PreviewProvider {
    static var previews: some View {
        @State var isVisibleLoadingView: Bool = false
        @State var message: String = "Loading..."
        LoadingDialog(isVisibleLoadingView: $isVisibleLoadingView,
                      message: $message)
            .edgesIgnoringSafeArea(.all)
    }
}
