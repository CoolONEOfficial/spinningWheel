//
//  ViewController.swift
//  spinningWheel
//
//  Created by Nickolay Truhin on 09.12.2021.
//

import UIKit

class WheelViewController: UIViewController {
    
    @IBOutlet weak private var wheelView: WheelView!
    @IBOutlet weak private var logoView: UIImageView!
    
    let viewModel: WheelViewModeling = WheelViewModel()
    
    private var isRotating = false {
        didSet {
            guard oldValue != isRotating else { return }
            if isRotating {
                viewModel.didStartRoll()
            } else {
                viewModel.didEndRoll()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeViewModel()
        configureUI()
    }

    private func observeViewModel() {
        viewModel.rows.listeners.append { [weak self] _ in
            self?.wheelView.setNeedsDisplay()
        }
    }
    
    private func configureUI() {
        wheelView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:))))
        
        let maskLayer = CAGradientLayer()
        maskLayer.frame = logoView.bounds
        maskLayer.shadowRadius = 5
        maskLayer.shadowPath = CGPath(roundedRect: logoView.bounds.insetBy(dx: 5, dy: 5), cornerWidth: 10, cornerHeight: 10, transform: nil)
        maskLayer.shadowOpacity = 1
        maskLayer.shadowOffset = CGSize.zero
        maskLayer.shadowColor = UIColor.white.cgColor
        logoView.layer.mask = maskLayer
    }
    
    func rotate(_ count: Double) {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2 * count)
        rotation.duration = abs(count)
        rotation.isCumulative = true
        rotation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        rotation.isRemovedOnCompletion = false
        rotation.fillMode = .forwards
        wheelView.layer.add(rotation, forKey: "rotationAnimation")
        
        isRotating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + rotation.duration) { [self] in
            isRotating = false
        }
    }

    var lastRotation: CGFloat = 0
    var startRotation: CGFloat = 0
    var previousRotations: [CGFloat] = []
    @objc func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil, !isRotating else {return}
        let piece = gestureRecognizer.view!
        
        let location = gestureRecognizer.location(in: piece)
        let res = location - piece.center
        let rotation = atan2(res.y,  res.x) / .pi * 360 / 2 + 180 // 0-360
        
        if gestureRecognizer.state == .began {
            startRotation = rotation
        }

        let diffRotation = startRotation - rotation
        let showRotation = lastRotation - diffRotation

        wheelView.rotation = lastRotation - diffRotation
        wheelView.setNeedsDisplay()
        
        if gestureRecognizer.state == .ended {
            lastRotation = showRotation
            
            let prevDiffRotation = (previousRotations.first ?? 0) - rotation
            rotate(prevDiffRotation * -3)
        }
        
        if gestureRecognizer.state == .changed {
            previousRotations.append(rotation)
            if previousRotations.count > 2 {
                previousRotations.removeFirst(1)
            }
        }
    }

    @IBAction func appendTapped(_ sender: Any) {
        viewModel.addRow()
    }

    @IBAction func popTapped(_ sender: Any) {
        viewModel.popRow()
    }
}

extension WheelViewController: WheelDataSource {
    var count: Int {
        viewModel.rows.value.count
    }

    func row(for index: Int) -> RowModel {
        viewModel.rows.value[index]
    }
}
