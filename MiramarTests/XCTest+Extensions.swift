//
//  XCTest+Extensions.swift
//  SimpleObservablesTests
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

import XCTest

public func XCTAssertEqual<T>(_ expression1: @autoclosure () -> (T,T),
                              _ expression2: @autoclosure () -> (T,T),
                              _ message: @autoclosure () -> String = "",
                              file: StaticString = #file,
                              line: UInt = #line) where T : Equatable {
    let expr1 = expression1()
    let expr2 = expression2()
    
    guard expr1 == expr2 else {
        Fail(.equal, [expr1, expr2], message: message, file: file, line: line)
        return
    }
}

public func XCTAssertEqual<T>(_ expression1: @autoclosure () -> T?,
                              _ expression2: @autoclosure () -> T,
                              _ message: @autoclosure () -> String = "",
                              file: StaticString = #file,
                              line: UInt = #line) where T : Equatable {
    guard let expr1 = expression1() else {
        Fail(.equal, [nil, expression2()], message: message, file: file, line: line)
        return
    }
    XCTAssertEqual(expr1, expression2(), message(), file: file, line: line)
}

public func XCTAssertEqual<T>(_ expression1: @autoclosure () -> [T]?,
                              _ expression2: @autoclosure () -> [T],
                              _ message: @autoclosure () -> String = "",
                              file: StaticString = #file,
                              line: UInt = #line) where T : Equatable {
    guard let expr1 = expression1() else {
        Fail(.equal, [nil, expression2()], message: message, file: file, line: line)
        return
    }
    XCTAssertEqual(expr1, expression2(), message(), file: file, line: line)
}

public func XCTAssertEqual<T>(_ expression1: @autoclosure () -> [[T]]?,
                              _ expression2: @autoclosure () -> [[T]],
                              _ message: @autoclosure () -> String = "",
                              file: StaticString = #file,
                              line: UInt = #line) where T : Equatable {
    guard let expr1 = expression1() else {
        Fail(.equal, [nil, expression2()], message: message, file: file, line: line)
        return
    }
    XCTAssertEqual(expr1, expression2(), message(), file: file, line: line)
}

public func XCTAssertEqual<T>(_ expression1: @autoclosure () -> [[T]],
                              _ expression2: @autoclosure () -> [[T]],
                              _ message: @autoclosure () -> String = "",
                              file: StaticString = #file,
                              line: UInt = #line) where T : Equatable {
    let expr1 = expression1()
    let expr2 = expression2()
    guard expr1.count == expr2.count else {
        Fail(.equal, [expr1, expr2], message: message, file: file, line: line)
        return
    }
    for (e1, e2) in zip(expr1, expr2) {
        guard e1 == e2 else {
            Fail(.equal, [expr1, expr2], message: message, file: file, line: line)
            return
        }
    }
}

//MARK: - Private methods

private func Fail(_ assertion: _XCTAssertionType, _ values: [Any?], message: @autoclosure () -> String, file: StaticString, line: UInt) {
    switch assertion {
    case .equal:
        let descriptions = values.map { $0 == nil ? "nil" : String(describing: $0!) } + ["", ""]
        let description = "XCTAssertEqual failed: (\"\(descriptions[0])\") is not equal to (\"\(descriptions[1])\")"
        Fail(description, message: message, file: file, line: line)
    default:
        break
    }
}

private func Fail(_ description: String, message: @autoclosure () -> String, file: StaticString, line: UInt) {
    let msg = message()
    let desc = msg.isEmpty ? description : "\(description) - \(msg)"
    if let current = currentTestCase {
        current.recordFailure(
            withDescription: desc,
            inFile: String(describing: file),
            atLine: Int(line),
            expected: true)
    } else {
        XCTFail(desc, file: file, line: line)
    }
}

