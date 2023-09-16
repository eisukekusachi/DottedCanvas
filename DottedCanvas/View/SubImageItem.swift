//
//  SubImageItem.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import SwiftUI

struct SubImageItem: View {
    @Environment(\.colorScheme) var colorScheme

    var imageItem: SubImageData
    var selected: Bool
    let didTapVisibleButton: ((Bool) -> Void)

    var body: some View {
        ZStack {
            Color(backgroundColor)
                .cornerRadius(8)

            HStack {
                Spacer()
                    .frame(width: 8)

                Text(imageItem.title)
                    .font(.headline)
                    .foregroundColor(Color(textColor))

                Spacer()

                Text("Alpha: \(imageItem.alpha)")
                    .font(.subheadline)
                    .foregroundColor(Color(textColor))

                Spacer()

                Image(systemName: imageItem.isVisible ? "eye" : "eye.slash.fill")
                    .frame(width: 32, height: 32)
                    .foregroundColor(iconColor)
                    .onTapGesture {
                        didTapVisibleButton(!imageItem.isVisible)
                    }

                Spacer()
                    .frame(width: 8)
            }
        }
    }
}

// Colors
extension SubImageItem {
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
                if imageItem.isVisible {
                    return Color(uiColor: .black)
                } else {
                    return Color(uiColor: .darkGray)
                }
            } else {
                if imageItem.isVisible {
                    return Color(uiColor: .white)
                } else {
                    return Color(uiColor: .lightGray)
                }
            }
        } else {
            if colorScheme == .light {
                if imageItem.isVisible {
                    return Color(uiColor: .white)
                } else {
                    return Color(uiColor: .lightGray)
                }
            } else {
                if imageItem.isVisible {
                    return Color(uiColor: .black)
                } else {
                    return Color(uiColor: .darkGray)
                }
            }
        }
    }
}

struct SubImageItem_Previews: PreviewProvider {
    static var previews: some View {

        SubImageItem(
            imageItem: .init(title: "Test0"),
            selected: true,
            didTapVisibleButton: { _ in
                print("Code button actions")
        })
        SubImageItem(
            imageItem: .init(title: "Test1"),
            selected: false,
            didTapVisibleButton: { _ in
                print("Code button actions")
        })
    }
}
