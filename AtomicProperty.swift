//
//  AtomicProperty.swift
//  AtomicProperty
//
//  Created by Sisov on 14.12.2019.
//  Copyright © 2019 Sisov. All rights reserved.
//

import Foundation
@propertyWrapper
class AtomicProperty<T> {
    private var property: T?
    var wrappedValue: T? {
        get {
            var retVal: T?
            lock.sync { [unowned self] in retVal = self.property }
            return retVal
        }
        
        set {
            lock.async(flags: DispatchWorkItemFlags.barrier) { [unowned self] in
              self.property = newValue
            }
        }
    }
    
    init(_ property: T) {
        self.wrappedValue = property
    }
    
    private let lock: DispatchQueue = {
        var name = "AtomicProperty \(String(Int.random(in: 0...100000)))"
        let clzzName = String(describing: T.self)
        name += clzzName
        return DispatchQueue(label: name, attributes: .concurrent)
    }()
}

