//
//  AnyObservable.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

/// Represents objects that allow subscribing to
/// receive updates when some event occurs.
///
/// Implementers of this protocol are free to determine when
/// updates are sent to subscribers.
public protocol AnyObservable: AnyObject {
    associatedtype ValueType
    
    /// Create a subscription to this object, which will call
    /// this block when some event occurs. Returns an object
    /// that can be used to cancel the subscription.
    @discardableResult
    func observe(_ handler: @escaping (ValueType) -> Void) -> Observation
}

/// Represents objects that hold a value of any type and also allow subscribing to
/// receive updates when some event occurs.
///
/// Users will expect updates to be sent when the internal value changes.
public protocol AnyObservableValue: AnyObservable {
    /// The contained value
    var value: ValueType { get }
}
