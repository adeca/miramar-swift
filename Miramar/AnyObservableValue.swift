//
//  AnyObservableValue.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 29/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

/// Represents objects that hold a value of any type and also allow subscribing to
/// receive updates when some event occurs.
///
/// Users will expect updates to be sent when the internal value changes.
public protocol AnyObservableValue: AnyObservable {
    /// The contained value
    var value: ValueType { get }
}

//MARK: - Map

extension AnyObservableValue {
    public func map<U>(_ transform: @escaping (ValueType) -> U) -> Observable<U> {
        let observable = Observable({
            transform(self.value)
        })
        observable.track(self.notifier)
        return observable
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
        observable.track([self.notifier, other.notifier])
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
            if let observable = observable,
                let connection = _current.notifier.observeChange(observable) {
                _connections.append(connection)
            }
        }
        
        observable.track(self.notifier) {
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
}

//MARK: - stream

extension AnyObservableValue {
    public func stream() -> Stream<ValueType> {
        let signal = Stream<ValueType>()
        
        signal.track(observe { [weak signal] in signal?.notify($0) })
        return signal
    }
}

