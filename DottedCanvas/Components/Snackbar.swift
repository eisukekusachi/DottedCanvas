//
//  Snackbar.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct Snackbar: View {

    @Binding var isPresented: Bool

    @State var isBodyPresented: Bool = false
    @State var autoViewHidingTask: Task<Void, Never>?

    let imageSystemName: String
    let comment: String
    var displayTime: CGFloat = 3.0
    var fadeTime: CGFloat = 0.25

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                let insetBottom = geometry.safeAreaInsets.bottom
                let snackbarHeight = 64.0

                VStack(spacing: 0) {
                    Spacer()

                    ZStack {
                        Rectangle()
                            .foregroundColor(Color("snackbarBackground"))
                            .cornerRadius(16)
                            .padding(8)
                            .padding(.horizontal, 44)

                        HStack {
                            Image(systemName: imageSystemName)
                            Text(comment)
                        }
                    }
                    .frame(height: snackbarHeight)

                    Color(.clear)
                        .frame(height: insetBottom)
                }
                .offset(y: isBodyPresented ? 0 : snackbarHeight + insetBottom)

                .onTapGesture {
                    withAnimation(.easeOut(duration: fadeTime)) {
                        isBodyPresented = false
                    }

                    Task {
                        try? await Task.sleep(nanoseconds: UInt64(fadeTime * 1_000_000_000))

                        autoViewHidingTask?.cancel()

                        withAnimation(.easeOut(duration: fadeTime)) {
                            isPresented = false
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {

                withAnimation(.easeOut(duration: fadeTime)) {
                    isBodyPresented = true
                }

                autoViewHidingTask = Task {

                    try? await Task.sleep(nanoseconds: UInt64(displayTime * 1_000_000_000))
                    withAnimation(.easeOut(duration: fadeTime)) {
                        isBodyPresented = false
                    }

                    try? await Task.sleep(nanoseconds: UInt64(fadeTime * 1_000_000_000))
                    isPresented = false
                }
            }
        }
    }
}


struct Snackbar_Previews: PreviewProvider {
    static var previews: some View {
        @State var isViewPresented: Bool = true
        Snackbar(isPresented: $isViewPresented,
                 imageSystemName: "hand.thumbsup.fill",
                 comment: "Success")
    }
}
