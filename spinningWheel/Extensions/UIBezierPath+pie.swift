//
//  UIBezierPath+pie.swift
//  spinningWheel
//
//  Created by Nickolay Truhin on 23.12.2021.
//

import UIKit

extension UIBezierPath {

    static func pie(center: CGPoint, angle: CGFloat, outerRadius: CGFloat, centerAngle: CGFloat) -> UIBezierPath {
        let innerAngle: CGFloat = angle / 2
        let outerAngle: CGFloat = angle / 2
        let path = UIBezierPath()
        path.addArc(withCenter: center, radius: 0, startAngle: centerAngle - innerAngle, endAngle: centerAngle + innerAngle, clockwise: true)
        path.addArc(withCenter: center, radius: outerRadius, startAngle: centerAngle + outerAngle, endAngle: centerAngle - outerAngle, clockwise: false)
        path.close()
        return path
    }
}
