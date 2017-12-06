//
//  AnyObservableStream.swift
//  Miramar
//
//  Created by Agustin De Cabrera on 5/12/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

public protocol AnyObservableStream: AnyObservable {}

//MARK: - Map

extension AnyObservableStream {
    public func map<U>(_ transform: @escaping (ValueType) -> U) -> Stream<U> {
        let signal = Stream<U>()
        signal.track(observe { [weak signal] in
            guard let signal = signal else { return }
            
            signal.notify(transform($0))
        })
        
        return signal
    }
}

//MARK: - Combine

public enum Either<T,U> {
    case left(T)
    case right(U)
}

extension AnyObservableStream {
    public func combine<S: AnyObservableStream>(_ other: S) -> Stream<Either<ValueType, S.ValueType>> {
        return combine(other) { $0 }
    }
    
    public func combine<S: AnyObservableStream, V>(_ other: S, _ transform: @escaping (Either<ValueType, S.ValueType>) -> V) -> Stream<V> {
        let signal = Stream<V>()
        
        signal.track([
            observe { [weak signal] in
                signal?.notify(transform(.left($0)))
            },
            other.observe { [weak signal] in
                signal?.notify(transform(.right($0)))
            }
            ])
        
        return signal
    }
}

//MARK: - flatMap

extension AnyObservableStream {
    public func flatMap<S: AnyObservableStream>(_ transform: @escaping (ValueType) -> S) -> Stream<S.ValueType> {
        let signal = Stream<S.ValueType>()
        
        var _current: S?
        var _connections: [Disposable?] = []
        
        let refreshConnection = { [weak signal] in
            _connections.removeAll()
            guard signal != nil,
                let current = _current else { return }
            
            let connection = current.observe { [weak signal] in
                signal?.notify($0)
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

extension AnyObservableStream {
    public func reduce<T>(initial: T, _ transform: @escaping (T, ValueType) -> T) -> Stream<T> {
        var value = initial
        return map {
            value = transform(value, $0)
            return value
        }
    }
}

//MARK: - observable

extension AnyObservableStream {
    public func observable(initial: ValueType) -> Observable<ValueType> {
        var value = initial
        let observable = Observable({ value })
        
        observable.track(self) {
            value = $0
        }
        return observable
    }
}
