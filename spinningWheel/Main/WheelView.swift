//
//  WheelView.swift
//  spinningWheel
//
//  Created by Nickolay Truhin on 09.12.2021.
//

import UIKit

protocol WheelDataSource {
    var count: Int { get }
    func row(for index: Int) -> UIView
}

class WheelView: UIView {
    var dataSource: WheelDataSource! {
        didSet {
            guard dataSource != nil else { return }
            reload()
        }
    }

    var rotation: CGFloat = 0 {
        didSet {
            debugPrint(rotation)
            //transform = .init(rotationAngle: rotation.truncatingRemainder(dividingBy: 360) / 360 * .pi)
        }
    }

    func reload() {
        subviews.forEach { $0.removeFromSuperview() }
        
        let size = min(bounds.width, bounds.height)
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        let count = dataSource.count
        let pie = Double.pi / Double(count) * 2
        let length: CGFloat = 2 * .pi * (size / 2)
        let pieWidth: CGFloat = length / CGFloat(count)
        for index in 0..<count {
            let view = dataSource.row(for: index)
            
            addSubview(view)
            view.frame = .init(origin: .zero, size: .init(width: pieWidth, height: size / 2))
            view.center = center
            
            let layer = CAShapeLayer()
            layer.path = maskPath(center: .init(x: view.frame.width / 2, y: view.frame.height), angle: pie, outerRadius: size / 2, centerAngle: .pi * 3 / 2).cgPath
            view.layer.mask = layer
            
            view.transform = .init(rotationAngle: pie * Double(index)).translatedBy(x: 0, y: -size / 4)
        }
    }

    func maskPath(center: CGPoint, angle: CGFloat, outerRadius: CGFloat, centerAngle: CGFloat) -> UIBezierPath {
        let innerAngle: CGFloat = angle / 2
        let outerAngle: CGFloat = angle / 2
        let path = UIBezierPath()
        path.addArc(withCenter: center, radius: 0, startAngle: centerAngle - innerAngle, endAngle: centerAngle + innerAngle, clockwise: true)
        path.addArc(withCenter: center, radius: outerRadius, startAngle: centerAngle + outerAngle, endAngle: centerAngle - outerAngle, clockwise: false)
        path.close()
        return path
    }
}
