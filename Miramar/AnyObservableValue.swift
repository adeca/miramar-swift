//
//  AnyObservableValue.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 29/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

/// Represents objects that hold a value of any type and also allow subscribing to
/// receive updates when the internal value changes.
public protocol AnyObservableValue: AnyObservable, AnyObject {
    associatedtype ValueType
    
    /// The contained value
    var value: ValueType { get }
    
    /// Create a subscription to this object, which sohuld call
    /// this block when the value changes.
    @discardableResult
    func observe(_ handler: @escaping (ValueType) -> Void) -> Observation
}

//MARK: - AnyObservable

extension AnyObservableValue {
    @discardableResult
    public func observeChange(_ handler: @escaping () -> Void) -> Observation {
        return observe { _ in handler() }
    }
}

//MARK: - Map

extension AnyObservableValue {
    public func map<U>(_ transform: @escaping (ValueType) -> U) -> Observable<U> {
        let observable = Observable({
            transform(self.value)
        })
        observable.track(self)
        return observable
    }
    
    public func map<U>(_ keyPath: KeyPath<ValueType, U>) -> Observable<U> {
        return map { $0[keyPath: keyPath] }
    }
}

//MARK: - Combine

extension AnyObservableValue {
    public func combine<T: AnyObservableValue>(_ other: T) -> Observable<(ValueType, T.ValueType)> {
        return combine(other) { ($0, $1) }
    }
    
    public func combine<T: AnyObservableValue, U>(_ other: T, _ transform: @escaping (ValueType, T.ValueType) -> U) -> Observable<U> {
        let observable = Observable({
            transform(self.value, other.value)
        })
        observable.track([self, other])
        return observable
    }
}

//MARK: - flatMap

extension AnyObservableValue {
    public func flatMap<O: AnyObservableValue>(_ transform: @escaping (ValueType) -> O) -> Observable<O.ValueType> {
        var _current = transform(self.value)
        let observable = Observable({ _current.value })
        
        var _connections: [Disposable?] = []
        let refreshConnection = { [weak observable] in
            _connections.removeAll()
            if let observable = observable {
                let connection = _current.observeChange(observable).disposable
                _connections.append(connection)
            }
        }
        
        observable.track(self) {
            _current = transform(self.value)
            refreshConnection()
        }
        refreshConnection()
        
        return observable
    }
}

//MARK: - reduce

extension AnyObservableValue {
    public func reduce<U>(initial: U, _ transform: @escaping (U, ValueType) -> U) -> Observable<U> {
        var value = initial
        return map {
            value = transform(value, $0)
            return value
        }
    }
    
    public func reduce(_ transform: @escaping (ValueType, ValueType) -> ValueType) -> Observable<ValueType> {
        return reduce(initial: self.value, transform)
    }
}

//MARK: - filter

extension AnyObservableValue {
    public func filter(_ isIncluded: @escaping (_ old: ValueType, _ new: ValueType) -> Bool) -> Observable<ValueType> {
        var previous = self.value
        
        let observable = Observable({ previous })
        observable.track(observe { [weak observable] new in
            defer { previous = new }
            
            guard let observable = observable,
                isIncluded(previous, new) else { return }
            
            observable.valueUpdated()
        })
        return observable
    }
}

//MARK: - signal

extension AnyObservableValue {
    public func signal() -> Signal<ValueType> {
        let signal = Signal<ValueType>()
        
        let observation = observe { [weak signal] in signal?.send($0) }
        signal.track(observation)
        
        return signal
    }
}

//MARK: - operators

public func && <A, B>(lhs: A, rhs: B) -> Observable<Bool>
    where A: AnyObservableValue, A.ValueType == Bool, B: AnyObservableValue, B.ValueType == Bool {
    return lhs.combine(rhs) { $0 && $1 }.filter(!=)
}

public func || <A, B>(lhs: A, rhs: B) -> Observable<Bool>
    where A: AnyObservableValue, A.ValueType == Bool, B: AnyObservableValue, B.ValueType == Bool {
    return lhs.combine(rhs) { $0 || $1 }.filter(!=)
}
