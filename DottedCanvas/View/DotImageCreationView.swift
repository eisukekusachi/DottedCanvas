//
//  DotImageCreationView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct DotImageCreationView: View {
    @Binding var isViewPresented: Bool
    @ObservedObject var creationData: DotImageCreationData
    var completion: (() -> Void)?

    private let previewViewSize: CGFloat = min(500, UIScreen.main.bounds.width * 0.6)
    private let sliderWidth: CGFloat = 16
    private let spacing: CGFloat = 12
    private let sliderStyle = SliderStyleImpl(trackLeftColor: GlobalData.getAssetColor(.trackColor))
    private let buttonSize: CGFloat = 20

    @State private var scrollViewEnabled: Bool = true

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
            SubImagePreviewView(viewSize: previewViewSize).environmentObject(creationData)
        }
    }

    private var clearButton: some View {
        HStack {
            Spacer()
            Button(action: {
                creationData.reset()
            }, label: {
                Text("Reset").buttonTextModifier(size: 16)
            })
        }
    }

    private var offsetLabelSection: some View {
        HStack {
            Text("OffsetX: ").font(.footnote)
            Text("\(creationData.offsetX)").font(.footnote)
            Spacer().frame(width: 24)
            Text("OffsetY: ").font(.footnote)
            Text("\(creationData.offsetY)").font(.footnote)
        }
    }

    private var offsetSlidersSection: some View {
        VStack(spacing: spacing) {
            TwoRowsSliderView(title: "OffsetX", value: $creationData.offsetX, style: sliderStyle, range: -256 ... 256)
            TwoRowsSliderView(title: "OffsetY", value: $creationData.offsetY, style: sliderStyle, range: -256 ... 256)
        }
    }

    private var colorSlidersSection: some View {
        VStack(spacing: spacing) {
            TwoRowsSliderView(title: "Red", value: $creationData.red, style: creationData.redStyle)
            TwoRowsSliderView(title: "Green", value: $creationData.green, style: creationData.greenStyle)
            TwoRowsSliderView(title: "Blue", value: $creationData.blue, style: creationData.blueStyle)
        }
    }

    private var dotSlidersSection: some View {
        VStack(spacing: spacing) {
            TwoRowsSliderView(title: "Size", value: $creationData.diameter, style: sliderStyle, range: 1 ... 256)
            TwoRowsSliderView(title: "Spacing", value: $creationData.spacing, style: sliderStyle, range: 0 ... 250)
        }
    }

    private var createImageButton: some View {
        Button(action: {
            completion?()
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

struct DotImageCreationView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isViewPresented: Bool = true
        let creationData = DotImageCreationData()

        DotImageCreationView(isViewPresented: $isViewPresented, creationData: creationData) {
            print("Image creation completed")
        }
    }
}
