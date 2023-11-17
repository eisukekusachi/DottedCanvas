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
    private let sliderWidth: CGFloat = 16
    private let spacing: CGFloat = 12
    private let sliderStyle = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))
    private let buttonSize: CGFloat = 20

    @State private var scrollViewEnabled: Bool = true

    init(isViewPresented: Binding<Bool>,
         data: SubImageModel,
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
                previewSection
                Spacer().frame(height: 8)
                offsetSlidersSection.padding()
                colorSlidersSection.padding()
                dotSlidersSection.padding()
                Spacer()
            }.padding()
        }
    }

    private var previewSection: some View {
        HStack(alignment: .top) {
            SubImagePreviewView(viewModel: viewModel,
                                viewSize: previewViewSize)
        }
    }

    private var clearButton: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.data.reset()
            }, label: {
                Text("Reset").buttonTextModifier(size: 16)
            })
        }
    }

    private var offsetLabelSection: some View {
        HStack {
            Text("OffsetX: ").font(.footnote)
            Text("\(viewModel.data.offsetX)").font(.footnote)
            Spacer().frame(width: 24)
            Text("OffsetY: ").font(.footnote)
            Text("\(viewModel.data.offsetY)").font(.footnote)
        }
    }

    private var offsetSlidersSection: some View {
        VStack(spacing: spacing) {
            TwoRowsSliderView(title: "OffsetX", 
                              value: $viewModel.data.offsetX,
                              style: sliderStyle, range: -256 ... 256)
            TwoRowsSliderView(title: "OffsetY", 
                              value: $viewModel.data.offsetY,
                              style: sliderStyle, range: -256 ... 256)
        }
    }

    private var colorSlidersSection: some View {
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

    private var dotSlidersSection: some View {
        VStack(spacing: spacing) {
            TwoRowsSliderView(title: "Size", 
                              value: $viewModel.data.diameter,
                              style: sliderStyle, range: 1 ... 256)
            TwoRowsSliderView(title: "Spacing", 
                              value: $viewModel.data.spacing,
                              style: sliderStyle, range: 0 ... 250)
        }
    }

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
