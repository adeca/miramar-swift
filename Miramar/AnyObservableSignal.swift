//
//  AnyObservableSignal.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 5/12/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

/// Represents objects that allow subscribing to
/// receive updates when some event occurs.
///
/// Implementers of this protocol are free to determine when
/// updates are sent to subscribers.
public protocol AnyObservableSignal: AnyObservable, AnyObject {
    associatedtype ValueType
    
    /// Create a subscription to this object, which will call
    /// this block when some event occurs. Returns an object
    /// that can be used to cancel the subscription.
    @discardableResult
    func observe(_ handler: @escaping (ValueType) -> Void) -> Observation
}

//MARK: - AnyObservable

extension AnyObservableSignal {
    @discardableResult
    public func observeChange(_ handler: @escaping () -> Void) -> Observation {
        return observe { _ in handler() }
    }
}

//MARK: - Map

extension AnyObservableSignal {
    public func map<U>(_ transform: @escaping (ValueType) -> U) -> Signal<U> {
        let signal = Signal<U>()
        signal.track(observe { [weak signal] in
            guard let signal = signal else { return }
            
            signal.send(transform($0))
        })
        
        return signal
    }
}

//MARK: - Combine

public enum Either<T,U> {
    case left(T)
    case right(U)
}

extension AnyObservableSignal {
    public func combine<S: AnyObservableSignal>(_ other: S) -> Signal<Either<ValueType, S.ValueType>> {
        return combine(other) { $0 }
    }
    
    public func combine<S: AnyObservableSignal, V>(_ other: S, _ transform: @escaping (Either<ValueType, S.ValueType>) -> V) -> Signal<V> {
        let signal = Signal<V>()
        
        signal.track([
            observe { [weak signal] in
                signal?.send(transform(.left($0)))
            },
            other.observe { [weak signal] in
                signal?.send(transform(.right($0)))
            }
            ])
        
        return signal
    }
}

//MARK: - flatMap

extension AnyObservableSignal {
    public func flatMap<S: AnyObservableSignal>(_ transform: @escaping (ValueType) -> S) -> Signal<S.ValueType> {
        let signal = Signal<S.ValueType>()
        
        var _current: S?
        var _connections: [Disposable?] = []
        
        let refreshConnection = { [weak signal] in
            _connections.removeAll()
            guard signal != nil,
                let current = _current else { return }
            
            let connection = current.observe { [weak signal] in
                signal?.send($0)
                }.disposable
            _connections.append(connection)
        }
        
        signal.track(observe {
            _current = transform($0)
            refreshConnection()
        })
        
        return signal
    }
}

//MARK: - reduce

extension AnyObservableSignal {
    public func reduce<T>(initial: T, _ transform: @escaping (T, ValueType) -> T) -> Signal<T> {
        var value = initial
        return map {
            value = transform(value, $0)
            return value
        }
    }
}

//MARK: - observable

extension AnyObservableSignal {
    public func observable(initial: ValueType) -> Observable<ValueType> {
        var value = initial
        let observable = Observable({ value })
        
        observable.track(self) {
            value = $0
        }
        return observable
    }
}
