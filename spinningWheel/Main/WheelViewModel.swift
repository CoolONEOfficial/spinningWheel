//
//  WheelViewModel.swift
//  spinningWheel
//
//  Created by Nickolay Truhin on 12.12.2021.
//

import Foundation
import UIKit

protocol WheelViewModeling: AnyObject {
    var rows: Property<[RowModel]> { get }
    func addRow()
    func popRow()
    
    func didStartRoll()
    func didEndRoll(_ selectedIndex: Int)
}

class WheelViewModel: WheelViewModeling {
    private let localService: LocalServicing = LocalService()
    private let soundService: SoundServicing = SoundService()

    var rows: Property<[RowModel]> {
        localService.rows
    }
    
    var textBank: Set<String> = [
        "здоровья",
        "счастья",
        "успехов",
        "профессионального роста",
        "крепкой дружбы",
        "хорошего настроения",
        "эмоциональной стабильности",
        "приятных неожиданностей",
        "раскрытия талантов",
        "удачи",
        "спокойствия",
        "прогресса",
        "любви"
    ]
    
    var newRow: RowModel? {
        let test = textBank.subtracting(rows.value.map(\.text))
        guard let text = test.randomElement() else { return nil }
        return .init(color: .random(), date: .now, text: text)
    }
    
    func addRow() {
        if let newRow = newRow {
            rows.value.append(newRow)
        }
    }
    
    func popRow() {
        rows.value.removeLast()
    }
    
    private let localServicing: LocalServicing = LocalService()
    
    init() {
        soundService.playBackground()
    }
    
    func didStartRoll() {
        soundService.playRoll()
    }
    
    func didEndRoll(_ selectedIndex: Int) {
        soundService.playBackground()
        let row = rows.value[selectedIndex]
        let alertController = UIAlertController(title: "Желаю \(row.text)", message: "", preferredStyle: .alert)
        alertController.addAction(.init(title: "Спасибо", style: .cancel, handler: nil))
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
