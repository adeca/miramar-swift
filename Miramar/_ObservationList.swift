//
//  ObservationList.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

final class ObservationList<T> {
    typealias Token = AnyObject
    
    private var handlers: [Box<(T) -> Void>] = []
    
    var isEmpty: Bool { return handlers.isEmpty }
    
    func add(_ block: @escaping (T) -> Void) -> Token {
        let handler = Box(block)
        handlers.append(handler)
        
        return handler
    }
    
    func remove(_ handler: Token) {
        if let index = handlers.index(where: { $0 === handler }) {
            handlers.remove(at: index)
        }
    }
    
    func notify(_ value: @autoclosure () -> T) {
        let value = value()
        handlers.forEach {
            let handler = $0.internalValue
            handler(value)
        }
    }
}

extension ObservationList {
    func observe(target: Any?, _ block: @escaping (T) -> Void) -> Observation {
        let token = add(block)
        return Observation(target: target) {
            self.remove(token)
        }
    }
    
    func observeChange(_ block: @escaping () -> Void) -> Disposable {
        return observe(target: nil) { _ in block() }.disposable
    }
}

// Opaque wrappers over closure instances
final class Box<T> {
    var internalValue: T
    
    init(_ value: T) {
        self.internalValue = value
    }
}
