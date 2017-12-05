//
//  Notifier.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 30/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//


/// Internal protocol used to represent objects that will trigger
/// the given blocks when some event happens.
///
/// - Similar to `AnyObservable` but without an associated type.
protocol Notifier {
    func observeChange(_ handler: @escaping () -> Void) -> Disposable?
}

/// Internal protocol used to identify objects that can handle
/// events posted by Notifier instances.
protocol NotifierTarget: AnyObject {
    func notifierChanged()
}

extension Notifier {
    /// Convenience method that will subscribe the target to receive
    /// events without holding a strong reference to it. The `notifierChanged`
    /// method of the target will be called when the event is triggered.
    func observeChange(_ target: NotifierTarget) -> Disposable? {
        return observeChange { [weak target] in target?.notifierChanged() }
    }
}

//

extension AnyObservableValue {
    /// Convenient way to convert `AnyObservableValue` instances into `Notifier`
    /// instances. Used in operator methods (`map`, `combine`, etc.)
    ///
    /// Notes:
    /// - Both `Observable` and `Variable` implement this protocol.
    /// - If the object does not implement the protocol, a `stub` instance is created
    /// which never actually posts any events.
    internal var notifier: Notifier {
        guard let notifier = self as? Notifier else {
            return EmptyNotifier.shared
        }
        return notifier
    }
}

private struct EmptyNotifier: Notifier {
    static let shared = EmptyNotifier()
    private init() {}
    
    func observeChange(_ handler: @escaping () -> Void) -> Disposable? { return nil }
}
