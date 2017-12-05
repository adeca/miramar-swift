//
//  Observable.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

public class Observable<T>: AnyObservableValue, CustomStringConvertible {
    //MARK: Public vars
    
    public var value: T {
        return get()
    }
    
    public var description: String {
        return "\(type(of: self))(\(value))"
    }
    
    //MARK: Private vars
    
    /// When called this should return the current value for the observable
    private let get: () -> T

    /// List of current observers
    private var observers = ObservationList<T>()
    
    /// When this is released the object will no longer get notifications
    /// when a dependency is updated
    private var connection: Disposable?

    //MARK: Public methods
    
    @discardableResult
    public func observe(_ block: @escaping (T) -> Void) -> Observation {
        return observers.observe(target: self, block)
    }
    
    //MARK: Internal methods
    
    init(_ get: @escaping () -> T) {
        self.get = get
    }
 
    func valueUpdated() {
        observers.notify(value)
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
}

extension Observable: Notifier, NotifierTarget {
    //Notifier
    
    func observeChange(_ handler: @escaping () -> Void) -> Disposable? {
        return observers.connect(handler)
    }
    
    //NotifierTarget
    
    func notifierChanged() {
        valueUpdated()
    }
}
