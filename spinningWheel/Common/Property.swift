//
//  Property.swift
//  spinningWheel
//
//  Created by Nickolay Truhin on 12.12.2021.
//

import Foundation

class Property<T> {
    init(_ value: T) {
        self.value = value
    }
    
    var listeners: [(T) -> Void] = []
    
    var value: T {
        didSet {
            notifyListeners()
        }
    }

    func notifyListeners() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.notifyListeners()
            }
            return
        }
        for listener in listeners {
            listener(value)
        }
    }
}
