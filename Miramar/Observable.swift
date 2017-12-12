//
//  Observable.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

public class Observable<T>: AnyObservableValue, CustomStringConvertible {
    //MARK: Public vars
    
    /// The current value of the observable.
    public var value: T {
        return get()
    }
    
    public var description: String {
        return "\(type(of: self))(\(value))"
    }
    
    //MARK: Private vars
    
    /// When called this should return the current value for the observable
    private let get: () -> T
    
    ///
    private let signal = SignalEmitter<T>()
    
    /// When this is released the object will no longer get notifications
    /// when a dependency is updated
    private var connection: Disposable?

    //MARK: Public methods
    
    convenience init(constant: ValueType) {
        self.init({ constant })
    }
    
    @discardableResult
    public func observe(_ handler: @escaping (T) -> Void) -> Observation {
        return signal.observe(target: self, handler)
    }
    
    //MARK: Internal methods
    
    init(_ get: @escaping () -> T) {
        self.get = get
    }
 
    func valueUpdated() {
        signal.send(value)
    }
    
    func track(_ observation: Observation) {
        connection += observation.disposable
    }
    
    func track(_ observable: AnyObservable) {
        connection += observable.observeChange(self).disposable
    }
    
    func track(_ observables: [AnyObservable]) {
        connection += Disposable(observables.map {
            $0.observeChange(self).disposable
        })
    }
    
    func track(_ observable: AnyObservable, _ handler: @escaping () -> Void) {
        connection += Disposable([
            observable.observeChange(handler).disposable,
            observable.observeChange(self).disposable
        ])
    }
    
    func track<S: AnyObservableSignal>(_ signal: S, _ handler: @escaping (S.ValueType) -> Void) {
        signal.observe({ [weak self] in
            handler($0)
            self?.valueUpdated()
        })
    }
}

extension AnyObservable {
    @discardableResult
    func observeChange<T>(_ observable: Observable<T>) -> Observation {
        return observeChange { [weak observable] in
            observable?.valueUpdated()
        }
    }
}
