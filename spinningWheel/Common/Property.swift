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
            for listener in listeners {
                listener(value)
            }
        }
    }
}
