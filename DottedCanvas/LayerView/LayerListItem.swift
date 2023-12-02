//
//  LayerListItem.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct LayerListItem: View {
    @Environment(\.colorScheme) var colorScheme

    var subLayer: SubLayerModel
    var selected: Bool
    let didTapVisibleButton: ((Bool) -> Void)

    var body: some View {
        ZStack {
            Color(backgroundColor)
                .cornerRadius(8)

            HStack {
                Spacer()
                    .frame(width: 8)

                Text(subLayer.title)
                    .font(.headline)
                    .foregroundColor(Color(textColor))

                Spacer()

                Text("Alpha: \(subLayer.alpha)")
                    .font(.subheadline)
                    .foregroundColor(Color(textColor))

                Spacer()

                Image(systemName: subLayer.isVisible ? "eye" : "eye.slash.fill")
                    .frame(width: 32, height: 32)
                    .foregroundColor(iconColor)
                    .onTapGesture {
                        didTapVisibleButton(!subLayer.isVisible)
                    }

                Spacer()
                    .frame(width: 8)
            }
        }
    }
}

// Colors
extension LayerListItem {
    private var backgroundColor: UIColor {
        if !selected {
            return .clear
        } else {
            return GlobalData.getAssetColor(.component)
        }
    }
    private var textColor: UIColor {
        if !selected {
            return GlobalData.getAssetColor(.component)
        } else {
            return GlobalData.getAssetColor(.reversalComponent)
        }
    }
    private var iconColor: Color {
        if !selected {
            if colorScheme == .light {
                if subLayer.isVisible {
                    return Color(uiColor: .black)
                } else {
                    return Color(uiColor: .darkGray)
                }
            } else {
                if subLayer.isVisible {
                    return Color(uiColor: .white)
                } else {
                    return Color(uiColor: .lightGray)
                }
            }
        } else {
            if colorScheme == .light {
                if subLayer.isVisible {
                    return Color(uiColor: .white)
                } else {
                    return Color(uiColor: .lightGray)
                }
            } else {
                if subLayer.isVisible {
                    return Color(uiColor: .black)
                } else {
                    return Color(uiColor: .darkGray)
                }
            }
        }
    }
}

struct LayerListItem_Previews: PreviewProvider {
    static var previews: some View {
        LayerListItem(
            subLayer: .init(title: "Test0"),
            selected: true,
            didTapVisibleButton: { _ in
                print("Code button actions")
        })
        LayerListItem(
            subLayer: .init(title: "Test1"),
            selected: false,
            didTapVisibleButton: { _ in
                print("Code button actions")
        })
    }
}
