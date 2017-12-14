//
//  Signal.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 5/12/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

public class Signal<T>: AnyObservableSignal, CustomStringConvertible {
    //MARK: Public vars
    
    public var description: String {
        return "\(type(of: self))"
    }
    
    //MARK: Private var
    
    /// List of current observers
    private let observers = ObservationList<T>()
    
    /// When this is released the object will no longer get notifications
    /// when a dependency is updated
    private var connection: Disposable?
    
    //MARK: Public methods
    
    ///
    public init() {}
    
    @discardableResult
    public func observe(_ handler: @escaping (T) -> Void) -> Observation {
        return observe(target: self, handler)
    }
    
    //MARK: Internal methods
    
    func track(_ observation: Observation) {
        self.connection = observation.disposable
    }
    
    func track(_ observations: [Observation]) {
        self.connection = Disposable(observations.map { $0.disposable })
    }
    
    func send(_ value: @autoclosure () -> T) {
        guard !observers.isEmpty else { return }
        observers.notify(value())
    }
    
    func observe(target: Any?, _ handler: @escaping (T) -> Void) -> Observation {
        return observers.observe(target: target, handler)
    }
}
