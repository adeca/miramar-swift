//
//  Variable.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

/// An object that holds a Value of any type and also allows subscribing to
/// receive updates when this value changes.
public final class ObservableValue<T>: Observable<T> {
    //MARK: Public vars
    
    /// The variable's current value. When this value is modified
    /// and the `validate` block passes, then all subscribers of
    /// this object are notified, with the new value as a parameter.
    public override var value: T {
        get { return super.value }
        set { update(value: newValue, notify: true) }
    }
    
    //MARK: Private vars
    
    /// Optional validation before notifying a change in value
    private let validate: (_ from: T, _ to: T) -> Bool
    
    /// Modify the underlying value
    private let set: (T) -> Void
    
    //MARK: Public methods

    /// Creates a new instance with the given value and a validation block used to
    /// determine if subscribers should be notified when the value is changed.
    public init(_ value: T, validate: @escaping (_ from: T, _ to: T) -> Bool) {
        self.validate = validate
        
        var _value = value
        self.set = { _value = $0 }

        super.init({ _value })
    }
    
    /// Creates a new instance with the given value. Subscribers will always be
    /// notified when the value is changed.
    public convenience init(_ value: T) {
        self.init(value, validate: { _,_ in true })
    }
    
    //MARK: Private methods
    
    private func update(value: T, notify: Bool) {
        let oldValue = self.value
        set(value)
        
        if notify && validate(oldValue, value) {
            valueUpdated()
        }
    }
}

extension ObservableValue {
    public convenience init<U: AnyObject>(source: U, keyPath: WritableKeyPath<U, T>) {
        var source = source
        self.init(get: { source[keyPath: keyPath] },
                  set: { source[keyPath: keyPath] = $0 })
    }
}

extension ObservableValue where T: AnyObject {
    public func keyPath<U>(_ keyPath: WritableKeyPath<T, U>) -> ObservableValue<U> {
        return ObservableValue<U>(source: value, keyPath: keyPath)
    }
}

//MARK: - Convenience Extensions

extension ObservableValue where T == Void {
    /// Creates a new instance.
    public convenience init() {
        self.init(())
    }
}

extension ObservableValue where T: MRMOptionalConvertible {
    /// Creates a new instance with the given value. Subscribers will always
    /// be notified unless both the old and new values are `nil`
    public convenience init(_ value: T) {
        self.init(value, validate: {
            // avoid triggering notifications if new and old values are `nil`
            $0.optionalValue != nil || $1.optionalValue != nil
        })
    }
}

extension ObservableValue where T: Equatable {
    /// Creates a new instance with the given value. Subscribers will be
    /// notified only if the new value is not equal to the old.
    public convenience init(_ value: T) {
        self.init(value, validate: {
            // avoid triggering notifications if new and old values are equal
            $0 != $1
        })
    }
}

extension ObservableValue where T: Collection, T.Iterator.Element: Equatable {
    /// Creates a new instance with the given value. Subscribers will be
    /// notified only if the new value is not equal to the old.
    public convenience init(_ value: T) {
        self.init(value, validate: { (from, to) in
            // avoid triggering notifications if new and old values are equal
            return from.count != to.count
                || zip(from, to).contains { $0 != $1 }
        })
    }
}

// * resolve ambiguity between less-specific extensions that could conflict
extension ObservableValue where T: Equatable, T: Collection, T.Iterator.Element: Equatable {
    /// Creates a new instance with the given value. Subscribers will be
    /// notified only if the new value is not equal to the old.
    public convenience init(_ value: T) {
        self.init(value, validate: {
            // avoid triggering notifications if new and old values are equal
            return $0 != $1
        })
    }
}

extension ObservableValue where T: MRMOptionalConvertible, T.SomeValue: Equatable {
    /// Creates a new instance with the given value. Subscribers will be
    /// notified only if the new value is not equal to the old.
    public convenience init(_ value: T) {
        self.init(value, validate: {
            // avoid triggering notifications if new and old values are equal
            $0.optionalValue != $1.optionalValue
        })
    }
}
