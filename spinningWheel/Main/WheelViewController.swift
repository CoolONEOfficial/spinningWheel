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
    @IBOutlet weak private var arrowView: UIView!
    
    let viewModel: WheelViewModeling = WheelViewModel()
    
    var lastRotation: CGFloat = 0
    var startRotation: CGFloat = 0
    var previousRotations: [CGFloat] = []
    
    var initialWheelFrame: CGRect!
    
    private var isRotating = false {
        didSet {
            //guard oldValue != isRotating else { return }
            if isRotating {
                viewModel.didStartRoll()
            } else {
                let global = UIApplication.shared.keyWindow?.rootViewController?.view
                let selIndex = wheelView.pieViews.map { wheelView.convert(.init(x: $0.frame.midX, y: $0.frame.midY), to: global) }.enumerated().sorted { $0.element.x > $1.element.x }.first!.offset
                viewModel.didEndRoll(selIndex)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeViewModel()
        configureUI()
        
        initialWheelFrame = .init(origin: wheelView.frame.origin + wheelView.superview!.frame.origin, size: wheelView.frame.size)
    }

    private func observeViewModel() {
        viewModel.rows.listeners.append { [weak self] _ in
            self?.wheelView.reload()
        }
    }
    
    private func configureUI() {
        wheelView.dataSource = self
        configureArrow()
    }
    
    private func configureArrow() {
        wheelView.bringSubviewToFront(arrowView)
        arrowView.backgroundColor = .systemYellow
        let layer = CAShapeLayer()
        layer.path = UIBezierPath.pie(center: .init(x: arrowView.bounds.width, y: arrowView.bounds.height / 2), angle: .pi / 4, outerRadius: arrowView.bounds.width, centerAngle: .pi).cgPath
        arrowView.transform = .init(rotationAngle: .pi)
        arrowView.layer.mask = layer
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

    @IBAction func appendTapped(_ sender: Any) {
        viewModel.addRow()
    }

    @IBAction func popTapped(_ sender: Any) {
        viewModel.popRow()
    }
}

extension WheelViewController: CAAnimationDelegate {
    func rotate(_ count: Double) {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        let toValue = Double.pi * count * 2
        rotation.toValue = NSNumber(value: toValue)
        rotation.duration = abs(count * 2)
        rotation.isCumulative = true
        rotation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        rotation.isRemovedOnCompletion = false
        rotation.fillMode = .forwards
        rotation.delegate = self
        
        wheelView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        isRotating = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag, let basicAnim = anim as? CABasicAnimation, let toVal = basicAnim.toValue as? NSNumber else { return }
        
        isRotating = false
        wheelView.layer.removeAllAnimations()
        wheelView.rotation = toVal.doubleValue / (2 * .pi) * 360
        lastRotation = wheelView.rotation
    }

    @objc func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil, !isRotating else {return}
        let piece = gestureRecognizer.view!
        
        let location = gestureRecognizer.location(in: piece)
        let topSafeArea = piece.safeAreaLayoutGuide.layoutFrame.origin.y
        let res = location - .init(x: initialWheelFrame.width / 2 + initialWheelFrame.origin.x, y: initialWheelFrame.height / 2 + initialWheelFrame.origin.y + topSafeArea)
        let rotation = atan2(res.y, res.x) / .pi * 360 / 2 + 180 // 0-360
        
        if gestureRecognizer.state == .began {
            startRotation = rotation
        }

        let diffRotation = startRotation - rotation
        let showRotation = lastRotation - diffRotation

        wheelView.rotation = showRotation
        
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
}

extension WheelViewController: WheelDataSource {
    var count: Int {
        viewModel.rows.value.count
    }
    
    var formatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        return dateFormatter
    }

    func row(for index: Int) -> UIView {
        let val = viewModel.rows.value[index]
        let view = UIView()
        view.backgroundColor = val.color
        
        let label = UILabel()
        label.text = formatter.string(from: val.date)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)
        ])
        
        return view
    }
}
