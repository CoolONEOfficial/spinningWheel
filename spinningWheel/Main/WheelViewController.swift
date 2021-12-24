//
//  ViewController.swift
//  spinningWheel
//
//  Created by Nickolay Truhin on 09.12.2021.
//

import UIKit
import DynamicColor

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
            guard oldValue != isRotating else { return }

            if isRotating {
                view.isUserInteractionEnabled = false
                UIView.animate(withDuration: 1) { [self] in
                    view.transform = .init(scaleX: 2, y: 2).translatedBy(x: -view.frame.width / 4, y: -view.frame.height / 6)
                }
                viewModel.didStartRoll()
            } else {
                view.isUserInteractionEnabled = true
                UIView.animate(withDuration: 1) { [self] in
                    view.transform = .identity
                }
                let global = UIApplication.shared.keyWindow?.rootViewController?.view
                let selIndex = wheelView.pieViews.map { wheelView.convert(.init(x: $0.frame.midX, y: $0.frame.midY), to: global) }.enumerated().sorted { $0.element.x > $1.element.x }.first!.offset
                viewModel.didEndRoll(selIndex)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeViewModel()
        
        
        initialWheelFrame = .init(origin: wheelView.frame.origin + wheelView.superview!.frame.origin, size: wheelView.frame.size)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureUI()
    }

    private func observeViewModel() {
        viewModel.rows.listeners.append { [weak self] _ in
            self?.wheelView.reload()
        }
    }
    
    private func configureUI() {
        wheelView.dataSource = self
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:))))
        
        configureArrow()
        configureLogo()
    }
    
    private func configureLogo() {
        let maskLayer = CAGradientLayer()
        maskLayer.frame = logoView.bounds
        maskLayer.shadowRadius = 5
        maskLayer.shadowPath = CGPath(roundedRect: logoView.bounds.insetBy(dx: 5, dy: 5), cornerWidth: 10, cornerHeight: 10, transform: nil)
        maskLayer.shadowOpacity = 1
        maskLayer.shadowOffset = CGSize.zero
        maskLayer.shadowColor = UIColor.white.cgColor
        logoView.layer.mask = maskLayer
    }
    
    private func configureArrow() {
        wheelView.bringSubviewToFront(arrowView)
        arrowView.backgroundColor = .systemYellow
        let layer = CAShapeLayer()
        layer.path = UIBezierPath.pie(center: .init(x: arrowView.bounds.width, y: arrowView.bounds.height / 2), angle: .pi / 4, outerRadius: arrowView.bounds.width, centerAngle: .pi).cgPath
        arrowView.transform = .init(rotationAngle: .pi)
        arrowView.layer.mask = layer
    }

    @IBAction func appendTapped(_ sender: Any) {
        viewModel.addRow()
    }

    @IBAction func popTapped(_ sender: Any) {
        viewModel.popRow()
    }
}

extension WheelViewController: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        isRotating = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag, let basicAnim = anim as? CABasicAnimation, let toVal = basicAnim.toValue as? NSNumber else { return }
        
        wheelView.layer.removeAllAnimations()
        wheelView.rotation = toVal.doubleValue / (2 * .pi) * 360
        lastRotation = wheelView.rotation
        isRotating = false
    }
}

private extension WheelViewController {
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

    func row(for index: Int) -> UIView {
        let val = viewModel.rows.value[index]
        let view = UIView()
        view.backgroundColor = val.color.withAlphaComponent(0.5)
        
        let label = UILabel()
        label.text = val.text
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9),
            label.heightAnchor.constraint(equalTo: view.widthAnchor)
        ])
        label.transform = .init(rotationAngle: -.pi / 2)
        
        return view
    }
}
