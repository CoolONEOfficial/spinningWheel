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
            reload()
        }
    }

    var rotation: CGFloat = 0 {
        didSet {
            transform = .init(rotationAngle: rotation.truncatingRemainder(dividingBy: 360) / 180 * .pi)
        }
    }
    
    var pieViews: [UIView] = []

    func reload() {
        guard dataSource != nil else { return }
        pieViews.forEach { $0.removeFromSuperview() }
        pieViews.removeAll()
        
        let size = min(bounds.width, bounds.height)
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        let count = dataSource.count
        let pie = Double.pi / Double(count) * 2
        let length: CGFloat = 2 * .pi * (size / 2)
        let pieWidth: CGFloat = length / CGFloat(count)
        for index in 0..<count {
            let view = dataSource.row(for: index)
            
            addSubview(view)
            pieViews.append(view)
            view.frame = .init(origin: .zero, size: .init(width: pieWidth, height: size / 2))
            view.center = center
            
            let layer = CAShapeLayer()
            layer.path = UIBezierPath.pie(center: .init(x: view.frame.width / 2, y: view.frame.height), angle: pie, outerRadius: size / 2, centerAngle: .pi * 3 / 2).cgPath
            view.layer.mask = layer
            
            view.transform = .init(rotationAngle: pie * Double(index)).translatedBy(x: 0, y: -size / 4)
        }
    }
}
