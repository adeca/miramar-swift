//
//  Observable+Caching.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 29/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

extension Observable {
    /// Creates an Observable that will cache the last value of the given object
    /// without holding a strong reference to this object.
    public convenience init<O: AnyObservableValue>(caching other: O) where O.ValueType == ValueType {
        self.init(caching: other, { $0 })
    }
    
    /// Creates an Observable that will cache the results of applying `transform` to the value
    /// of the given object without holding a strong reference to this object.
    public convenience init<O: AnyObservableValue>(caching other: O, _ transform: @escaping (O.ValueType) -> ValueType) {
        
        var value = transform(other.value)
        self.init({ value })
        
        track(other.notifier) { [weak other] in
            value = other.map({ transform($0.value) }) ?? value
        }
    }
    
    /// Creates an Observable that will cache the last value of the given object.
    public convenience init<O: AnyObservableStream>(caching other: O, initial: ValueType) where O.ValueType == ValueType {
        self.init(caching: other, initial: initial) { $0 }
    }
    
    /// Creates an Observable that will cache the results of applying `transform` to the value
    /// of the given object.
    public convenience init<O: AnyObservableStream>(caching other: O, initial: ValueType, _ transform: @escaping (O.ValueType) -> ValueType) {
        
        var value = initial
        self.init({ value })
        
        track(other) {
            value = transform($0)
        }
    }
}
