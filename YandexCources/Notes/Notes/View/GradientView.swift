//
//  GradientView.swift
//  Notes
//
//  Created by Timofei Sikorski on 8/27/19.
//  Copyright © 2019 SikorskiIT. All rights reserved.
//

import UIKit

fileprivate let basicColors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple]

class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let colorPointer = CAShapeLayer()
    private let colorPointerSize: CGFloat = 5
    
    private var colorUpdater: (UIColor) -> Void = { _ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func setup(colorUpdater: @escaping (UIColor) -> Void) {
        self.colorUpdater = colorUpdater
        colorUpdater(.red)
    }
}

// MARK: - Touches
extension GradientView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updatePicker(for: touch.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updatePicker(for: touch.location(in: self))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updatePicker(for: touch.location(in: self))
    }
    
    private func updatePicker(for location: CGPoint) {
        guard bounds.contains(location) else { return }
        colorPointer.isHidden = true
        colorUpdater(colorOfPoint(point: location))
        colorPointer.isHidden = false
        colorPointer.position = location
    }
}

// MARK: - Setup
private extension GradientView {

    func setupGradient() {
        gradientLayer.colors = basicColors.map { $0.cgColor }
        layer.addSublayer(gradientLayer)

        let pointerRect = CGRect(x: 0, y: 0, width: colorPointerSize, height: colorPointerSize)
        let pointerPath = UIBezierPath(ovalIn: pointerRect)
        colorPointer.path = pointerPath.cgPath
        colorPointer.fillColor = UIColor.clear.cgColor
        colorPointer.strokeColor = UIColor.black.cgColor
        colorPointer.lineWidth = colorPointerSize / 4
        colorPointer.frame = pointerRect
        colorPointer.frame = pointerRect
        layer.addSublayer(colorPointer)
        colorPointer.position = CGPoint(x: colorPointerSize, y: colorPointerSize)
    }
}


extension UIView {

    func colorOfPoint(point: CGPoint) -> UIColor {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        var pixelData: [UInt8] = [0, 0, 0, 0]

        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        context!.translateBy(x: -point.x, y: -point.y)

        self.layer.render(in: context!)

        let red: CGFloat = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green: CGFloat = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue: CGFloat = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha: CGFloat = CGFloat(pixelData[3]) / CGFloat(255.0)

        let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)

        return color
    }
}
