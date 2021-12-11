//
//  WheelView.swift
//  spinningWheel
//
//  Created by Nickolay Truhin on 09.12.2021.
//

import UIKit

protocol WheelDataSource {
    var count: Int { get }
    func color(for index: Int) -> UIColor
}

class WheelView: UIView {
    var dataSource: WheelDataSource!
    
    var rotation: CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        let size = min(rect.width, rect.height)
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        
        let count = dataSource.count
        let pie = Double.pi / Double(count) * 2
        for index in 0..<count {
            drawCell(center: center, size: size, start: pie * Double(index), end: pie * Double(index + 1), color: dataSource.color(for: index))
        }
    }

    func drawCell(center: CGPoint, size: CGFloat, start: Double, end: Double, color: UIColor) {
        let aPath = UIBezierPath()
        
        aPath.move(to: center)
    
        aPath.addLines(point(start) * size / 2, point(end) * size / 2, origin: center)
        
        aPath.rotate(degree: rotation.truncatingRemainder(dividingBy: 360), origin: center)
        
        aPath.close()

        color.set()
        aPath.stroke()
        
        aPath.fill()
    }

    // value: -pi/2...pi/2
    func point(_ value: Double) -> CGPoint {
        .init(x: sin(value), y: cos(value))
    }
}

extension UIBezierPath {
    func addLines(_ points: CGPoint..., origin: CGPoint = .zero) {
        
        for point in points {
            
            addLine(to: point + origin)
        }
    }
    
    func rotate(degree: CGFloat, origin: CGPoint) {
        let radians = degree / 180.0 * .pi
        var transform: CGAffineTransform = .identity
        transform = transform.translatedBy(x: origin.x, y: origin.y)
        transform = transform.rotated(by: radians)
        transform = transform.translatedBy(x: -origin.x, y: -origin.y)
        apply(transform)
    }
    
    func rotate(rotationAngle: CGFloat) {
        let x_translation = -bounds.width/2
        let y_translation = -bounds.height/2

        apply(CGAffineTransform(translationX: x_translation, y: y_translation))
        apply(CGAffineTransform(rotationAngle: rotationAngle))
        apply(CGAffineTransform(translationX: -x_translation, y: -y_translation))
    }
}
