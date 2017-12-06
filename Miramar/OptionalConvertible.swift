//
//  OptionalConvertible.swift
//  Miramar
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

/// A type that can be represented as an `Optional`
public protocol MRMOptionalConvertible {
    associatedtype SomeValue
    
    var optionalValue: SomeValue? { get }
}

extension Optional: MRMOptionalConvertible {
    public var optionalValue: Wrapped? { return self }
}
