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
}

class WheelViewModel: WheelViewModeling {
    private let localService: LocalServicing = LocalService()

    var rows: Property<[RowModel]> {
        localService.rows
    }
    
    func addRow() {
        rows.value.append(.init(color: .random(), date: .now))
    }
    
    func popRow() {
        rows.value.removeLast()
    }
    
    private let localServicing: LocalServicing = LocalService()
    
    
}
