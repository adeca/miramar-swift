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
    private let signal = Signal<T>()
    
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
        signal.notify(value)
    }
    
    func track(_ notifier: Notifier) {
        self.connection = notifier.observeChange(self)
    }
    
    func track(_ notifier: Notifier, _ handler: @escaping () -> Void) {
        self.connection = Disposable([
            notifier.observeChange(handler),
            notifier.observeChange(self)
            ])
    }
    
    func track(_ notifiers: [Notifier]) {
        self.connection = Disposable(notifiers.flatMap { $0.observeChange(self) })
    }
    
    func track(_ observation: Observation) {
        self.connection = observation.disposable
    }
    
    func track<S: AnyObservableStream>(_ signal: S, _ handler: @escaping (S.ValueType) -> Void) {
        signal.observe({ [weak self] in
            handler($0)
            self?.valueUpdated()
        })
    }
}

extension Observable: Notifier, NotifierTarget {
    //Notifier
    
    func observeChange(_ handler: @escaping () -> Void) -> Disposable? {
        return signal.observeChange(handler)
    }
    
    //NotifierTarget
    
    func notifierChanged() {
        valueUpdated()
    }
}
