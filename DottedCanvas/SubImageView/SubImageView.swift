//
//  SubImageView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct SubImageView: View {
    @Binding var isViewPresented: Bool
    @ObservedObject var viewModel: SubImageViewModel
    var completion: ((SubImageModel, UIImage?) -> Void)?

    private let previewViewSize: CGFloat = min(500, UIScreen.main.bounds.width * 0.6)
    private let spacing: CGFloat = 12
    private let sliderStyle = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))

    @State private var scrollViewEnabled: Bool = true

    static let imageSize: CGSize = CGSize(width: 1000, height: 1000)

    init(isViewPresented: Binding<Bool>,
         data: SubImageModel?,
         completion: ((SubImageModel, UIImage?) -> Void)?) {
        self._isViewPresented = isViewPresented
        self.viewModel = SubImageViewModel(data: data)
        self.completion = completion
    }

    var body: some View {
        ScrollView(scrollViewEnabled ? .vertical : []) {
            VStack {
                HStack {
                    createImageButton
                    Spacer()
                    clearButton
                }
                Spacer().frame(height: 18)

                previewImageView

                Spacer().frame(height: 8)
                offsetSliders.padding()
                colorSliders.padding()
                dotSliders.padding()
                Spacer()

            }.padding()
        }
    }
}

extension SubImageView {
    private var createImageButton: some View {
        Button(action: {
            completion?(viewModel.data, viewModel.dotImage)
            isViewPresented = false
        }, label: {
            ZStack {
                Text("Create Image")
                    .bold()
                    .foregroundColor(.white)
                    .padding(8)
                    .padding(.horizontal, 8)
                    .background(Color.blue)
                    .cornerRadius(44)
            }
        }).tint(.white)
    }
    private var clearButton: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.data = SubImageModel()
                
            }, label: {
                Text("Reset").buttonTextModifier(size: 16)
            })
        }
    }

    private var previewImageView: some View {
        HStack(alignment: .top) {
            SubImagePreviewView(viewModel: viewModel,
                                viewSize: previewViewSize)
        }
    }

    private var offsetSliders: some View {
        VStack(spacing: spacing) {
            TwoRowsSliderView(title: "OffsetX", 
                              value: $viewModel.data.offsetX,
                              style: sliderStyle, range: -256 ... 256)
            TwoRowsSliderView(title: "OffsetY", 
                              value: $viewModel.data.offsetY,
                              style: sliderStyle, range: -256 ... 256)
        }
    }

    private var colorSliders: some View {
        VStack(spacing: spacing) {
            TwoRowsSliderView(title: "Red", 
                              value: $viewModel.data.red,
                              style: viewModel.data.redStyle)
            TwoRowsSliderView(title: "Green",
                              value: $viewModel.data.green,
                              style: viewModel.data.greenStyle)
            TwoRowsSliderView(title: "Blue",
                              value: $viewModel.data.blue,
                              style: viewModel.data.blueStyle)
        }
    }
    private var dotSliders: some View {
        VStack(spacing: spacing) {
            TwoRowsSliderView(title: "Size", 
                              value: $viewModel.data.diameter,
                              style: sliderStyle, range: 1 ... 256)
            TwoRowsSliderView(title: "Spacing", 
                              value: $viewModel.data.spacing,
                              style: sliderStyle, range: 0 ... 250)
        }
    }
}

struct SubImageView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isViewPresented: Bool = true
        
        SubImageView(isViewPresented: $isViewPresented,
                     data: SubImageModel()) { _, _ in
            print("result")
        }
    }
}
