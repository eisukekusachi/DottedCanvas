//
//  TwoRowsSliderView.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/25.
//

import SwiftUI

struct TwoRowsSliderView: View {

    let title: String
    @Binding var value: Int
    let style: SliderStyle
    var range = 0 ... 255
    var buttonSize: CGFloat = 20
    var valueLabelWidth: CGFloat = 64

    var body: some View {
        VStack(spacing: 4) {
            IntSlider(value: $value, in: range)
                .environment(\.sliderStyle, style)
            buttons
        }
    }

    private var buttons: some View {
        HStack(spacing: 0) {
            minusButton
            Spacer()
            valueLabel
            Spacer()
            plusButton
        }
    }

    private var minusButton: some View {
        Button(action: {
            value = max(value - 1, range.lowerBound)
        },
               label: {
            Image(systemName: "minus")
                .frame(width: buttonSize, height: buttonSize)
                .foregroundColor(.primary)
        })
    }

    private var plusButton: some View {
        Button(action: {
            value = min(value + 1, range.upperBound)
        },
               label: {
            Image(systemName: "plus")
                .frame(width: buttonSize, height: buttonSize)
                .foregroundColor(.primary)
        })
    }

    private var valueLabel: some View {
        HStack {
            Spacer()
            Text("\(title):")
                .font(.footnote)
                .frame(width: valueLabelWidth, alignment: .trailing)

            Spacer()
                .frame(width: 12)

            Text("\(value)")
                .font(.footnote)
                .frame(width: valueLabelWidth, alignment: .leading)
            Spacer()
        }
    }
}

struct TwoRowsSliderView_Previews: PreviewProvider {
    static var previews: some View {

        @State var data = DotImageCreationData()

        VStack {
            TwoRowsSliderView(title: "Red", value: $data.red, style: data.redStyle)
            TwoRowsSliderView(title: "Geen", value: $data.green, style: data.greenStyle)
            TwoRowsSliderView(title: "Blue", value: $data.blue, style: data.blueStyle)
        }
        .padding()
    }
}
