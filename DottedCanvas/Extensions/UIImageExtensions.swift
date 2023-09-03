//
//  UIImageExtensions.swift
//  DottedCanvas
//
//  Created by Eisuke Kusachi on 2023/08/16.
//

import UIKit

extension UIImage {
    convenience init?(circleSize: CGSize, color: UIColor = .clear) {
        UIGraphicsBeginImageContextWithOptions(circleSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        color.setFill()
        UIBezierPath(ovalIn: CGRect(x: 0.0,
                                    y: 0.0,
                                    width: circleSize.width,
                                    height: circleSize.height)).fill()

        if let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
            self.init(cgImage: cgImage)

        } else {
            return nil
        }
    }
    convenience init?(with size: CGSize, color: UIColor = .clear) {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }

        color.setFill()
        UIBezierPath(rect: CGRect(x: 0.0,
                                  y: 0.0,
                                  width: size.width,
                                  height: size.height)).fill()

        if let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
            self.init(cgImage: cgImage)

        } else {
            return nil
        }
    }

    static func dotImage(with size: CGSize,
                         dotSize: CGFloat = 24,
                         spacing: CGFloat = 24,
                         offset: CGPoint = .zero,
                         color: UIColor = .black) -> UIImage {

        var verticalPoints: [CGPoint] = []
        let center: CGPoint = CGPoint(x: size.width * 0.5 + offset.x,
                                      y: size.height * 0.5 + offset.y)

        verticalPoints.append(center)

        var count = 1

        while true {
            let yPosition = (dotSize + spacing) * CGFloat(count) + center.y

            if yPosition < size.height + dotSize {
                verticalPoints.append(CGPoint(x: center.x, y: yPosition))
                count += 1

            } else {
                break
            }
        }

        count = 1

        while true {
            let yPosition = -(dotSize + spacing) * CGFloat(count) + center.y

            if 0 - dotSize < yPosition {
                verticalPoints.append(CGPoint(x: center.x, y: yPosition))
                count += 1

            } else {
                break
            }
        }

        var points: [CGPoint] = verticalPoints

        count = 1

        while true {
            let xPosition = (dotSize + spacing) * CGFloat(count) + center.x

            if xPosition < size.width + dotSize {
                verticalPoints.forEach { point in
                    points.append(CGPoint(x: xPosition, y: point.y))
                }
                count += 1

            } else {
                break
            }
        }

        count = 1

        while true {
            let xPosition = -(dotSize + spacing) * CGFloat(count) + center.x

            if 0 - dotSize < xPosition {
                verticalPoints.forEach { point in
                    points.append(CGPoint(x: xPosition, y: point.y))
                }
                count += 1

            } else {
                break
            }
        }

        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }

        let context: CGContext? = UIGraphicsGetCurrentContext()

        points.forEach {
            context?.setFillColor(color.cgColor)
            context?.fillEllipse(in: CGRect(x: $0.x - dotSize * 0.5,
                                            y: $0.y - dotSize * 0.5,
                                            width: dotSize,
                                            height: dotSize))
        }

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    static func checkered(with size: CGSize, dotSize: Int = 8, color0: UIColor = .lightGray, color1: UIColor = .white) -> UIImage {

        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()

        for y in stride(from: 0, to: size.height, by: CGFloat(dotSize)) {
            for x in stride(from: 0, to: size.width, by: CGFloat(dotSize)) {
                let isEvenRow = Int(y / CGFloat(dotSize)) % 2 == 0
                let isEvenColumn = Int(x / CGFloat(dotSize)) % 2 == 0
                let flag = (isEvenRow && isEvenColumn) || (!isEvenRow && !isEvenColumn)

                context?.setFillColor(flag ? color0.cgColor : color1.cgColor)
                context?.fill(CGRect(x: x, y: y, width: CGFloat(dotSize), height: CGFloat(dotSize)))
            }
        }

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    func merge(with image: UIImage, alpha: CGFloat) -> UIImage {
        let bottomImage = self

        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }

        let areaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height)
        bottomImage.draw(in: areaSize)

        image.draw(in: areaSize, blendMode: .normal, alpha: alpha)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    func resize(scale: CGFloat, option: CGFloat = 0.0) -> UIImage? {
        if scale == 1.0 { return self }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, false, option)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: newSize))

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resize(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resize(sideLength: CGFloat, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let newSize = CGSize(width: sideLength, height: sideLength * self.size.height / self.size.width)

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func withAlpha(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        draw(at: .zero, blendMode: .normal, alpha: alpha)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
