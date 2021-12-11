//
//  ViewController.swift
//  spinningWheel
//
//  Created by Nickolay Truhin on 09.12.2021.
//

import UIKit

class ViewController: UIViewController {
    
    var wheelView: WheelView! { view as? WheelView }
    
    var parts: [UIColor] = [.red, .green, .blue] {
        didSet {
            wheelView.setNeedsDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        wheelView.dataSource = self
        
        navigationController?.title = "test"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:))))
    }
    
//    var lastRotation: CGFloat = 0
//    var startRotation: CGFloat = 0
    @objc func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        let piece = gestureRecognizer.view!
        
        let location = gestureRecognizer.location(in: piece)
        let res = location - piece.center
        let rotation = atan2(res.y,  res.x) / .pi * 360 / 2 + 180 // 0-360

        //let diff = startRotation - rotation
        
//        debugPrint("rot \(rotation)")
//        debugPrint("start rot \(startRotation)")
//        debugPrint("diff \(diff)")
    
//        if gestureRecognizer.state == .began {
//            startRotation = rotation //(startRotation + rotation).truncatingRemainder(dividingBy: 360)
//        } else if gestureRecognizer.state == .ended {
//            lastRotation = rotation
//            //startRotation = startRotation - diff
//        }
        
        wheelView.rotation = rotation
        wheelView.setNeedsDisplay()
    }

    @IBAction func appendTapped(_ sender: Any) {
        parts.append(.random())
    }

    @IBAction func popTapped(_ sender: Any) {
        parts.removeLast()
    }
}

extension ViewController: WheelDataSource {
    var count: Int { parts.count }
    func color(for index: Int) -> UIColor {
        parts[index]
    }
}
