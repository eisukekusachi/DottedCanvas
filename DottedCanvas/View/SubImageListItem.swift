//
//  SubImageListItem.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct SubImageListItem: View {
    @Environment(\.colorScheme) var colorScheme

    var selected: Bool
    var imageData: SubImageData
    let onTapVisibleButton: ((SubImageData) -> Void)

    var body: some View {
        ZStack {
            Color(backgroundColor)
                .cornerRadius(8)

            HStack {
                Spacer()
                    .frame(width: 8)

                Text(imageData.title)
                    .font(.headline)
                    .foregroundColor(Color(textColor))

                Spacer()

                Text("Alpha: \(imageData.alpha)")
                    .font(.subheadline)
                    .foregroundColor(Color(textColor))

                Spacer()

                Image(systemName: imageData.isVisible ? "eye" : "eye.slash.fill")
                    .frame(width: 32, height: 32)
                    .foregroundColor(iconColor)
                    .onTapGesture {
                        onTapVisibleButton(imageData)
                    }

                Spacer()
                    .frame(width: 8)
            }
        }
    }
}

// Colors
extension SubImageListItem {
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
                if imageData.isVisible {
                    return Color(uiColor: .black)
                } else {
                    return Color(uiColor: .darkGray)
                }
            } else {
                if imageData.isVisible {
                    return Color(uiColor: .white)
                } else {
                    return Color(uiColor: .lightGray)
                }
            }
        } else {
            if colorScheme == .light {
                if imageData.isVisible {
                    return Color(uiColor: .white)
                } else {
                    return Color(uiColor: .lightGray)
                }
            } else {
                if imageData.isVisible {
                    return Color(uiColor: .black)
                } else {
                    return Color(uiColor: .darkGray)
                }
            }
        }
    }
}

struct SubImageListItem_Previews: PreviewProvider {
    static var previews: some View {

        SubImageListItem(selected: true,
                         imageData: .init(title: "Test0"),
                         onTapVisibleButton: { value in
            print(value)
        })
        SubImageListItem(selected: false,
                         imageData: .init(title: "Test1"),
                         onTapVisibleButton: { value in
            print(value)
        })
    }
}
