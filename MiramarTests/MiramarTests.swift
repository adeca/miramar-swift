//
//  MiramarTests.swift
//  MiramarTests
//
//  Created by Agustín de Cabrera on 28/11/17.
//  Copyright © 2017 Agustín de Cabrera. All rights reserved.
//

import XCTest
@testable import Miramar

class MiramarTests: BaseTestCase {
    typealias ValueType = String
    
    var callCount = 0
    
    func givenNoCalls() {
        callCount = 0
    }
    
    func thenVariable<T: Equatable>(_ variable: ObservableValue<T>, equals value: T, line: UInt = #line) {
        XCTAssertEqual(variable.value, value, "the current value should equal '\(value)'", line: line)
    }
    func thenObservableValue<T: Equatable>(_ observable: Observable<T>, equals value: T, line: UInt = #line) {
        XCTAssertEqual(observable.value, value, "the current value should equal '\(value)'", line: line)
    }
    func thenObservableValue<T: Equatable>(_ observable: Observable<(T,T)>, equals value: (T,T), line: UInt = #line) {
        XCTAssertEqual(observable.value, value, "the current value should equal '\(value)'", line: line)
    }
    
    func thenBlockIsNotCalled(line: UInt = #line) {
        XCTAssertEqual(callCount, 0, "the observation block should not be called", line: line)
    }
    func thenBlockIsCalled(line: UInt = #line) {
        XCTAssertEqual(callCount, 1, "the observation block should be called once", line: line)
    }
    func thenBlockIsCalled(times: Int, line: UInt = #line) {
        XCTAssertEqual(callCount, times, "the observation block should be called \(times) time(s)", line: line)
    }
    
    func whenObserving<T: AnyObservableValue>(_ observable: T) -> Observation {
        return observable.observe { _ in
            self.callCount += 1
        }
    }
    func whenObserving<T: AnyObservableSignal>(_ observable: T) -> Observation {
        return observable.observe { _ in
            self.callCount += 1
        }
    }
    
    //MARK: Test
    
    func testValue() {
        // given two different values
        let (value1, value2) = differentValues()
        
        // when creating an observable with a value
        let variable: ObservableValue<ValueType> = ObservableValue(value1, validate: {_,_ in true })
        let observable: Observable<ValueType> = variable
        
        thenVariable(variable, equals: value1)
        thenObservableValue(observable, equals: value1)
        
        // when changing the value
        variable.value = value2
        thenVariable(variable, equals: value2)
        thenObservableValue(observable, equals: value2)
    }
    
    func testObservation() {
        // given two different values and a Variable
        let (value1, value2) = differentValues()
        let variable = ObservableValue(value1, validate: {_,_ in true })
        
        // given an observation on the variable
        let observation = whenObserving(variable)
        
        // when changing the value
        variable.value = value2
        thenBlockIsCalled()
        
        observation.remove()
    }
    
    func testRetain() {
        let value = singleValue()
        // given a weak reference to a Variable
        weak var weakVariable: ObservableValue<ValueType>?
        
        // when creating a Variable and assigning it to the weak reference
        do {
            let variable = ObservableValue(value)
            weakVariable = variable
            XCTAssertNotNil(weakVariable)
            thenVariable(variable, equals: value)
        }
        
        // since no strong references to the variable exist, it is released
        XCTAssertNil(weakVariable)
    }
    
    func testRetainObservable() {
        let value = singleValue()
        // given a weak reference to a Variable and a strong reference to an observable
        weak var weakVariable: ObservableValue<ValueType>?
        var observable: Observable<ValueType>?
        
        // when creating a Variable and assigning it's `observable` property to the
        // strong reference
        do {
            let variable = ObservableValue(value)
            weakVariable = variable
            XCTAssertNotNil(weakVariable)
            observable = variable
            XCTAssertNotNil(observable)
            thenVariable(variable, equals: value)
        }
        
        // since a strong reference to the observable exists, the Variable is retained
        XCTAssertNotNil(observable)
        XCTAssertNotNil(weakVariable)
        
        // when the reference to the observable is removed, the Variable is released
        observable = nil
        XCTAssertNil(weakVariable)
        
    }
    
    func testRetainObservation() {
        let value = singleValue()
        // given a weak reference to a Variable and a strong reference to an observation
        weak var weakVariable: ObservableValue<ValueType>?
        var observation: Observation?
        
        // when creating a Variable and observing it and assigning the observation to
        // the strong reference
        do {
            let variable = ObservableValue(value)
            weakVariable = variable
            XCTAssertNotNil(weakVariable)
            observation = variable.observe { _ in }
            XCTAssertNotNil(observation)
            thenVariable(variable, equals: value)
        }
        
        // sicne a strong reference to the observation exists, the Variable is retained
        XCTAssertNotNil(observation)
        XCTAssertNotNil(weakVariable)
        
        // when the observation is removed, the Variable is released
        observation?.remove()
        XCTAssertNil(weakVariable)
    }
    
    func testRetainObservationWithoutRemoving() {
        let value = singleValue()
        // given a weak reference to a Variable and a strong reference to an observation
        weak var weakVariable: ObservableValue<ValueType>?
        var observation: Observation?
        
        // when creating a Variable and observing it and assigning the observation to
        // the strong reference
        do {
            let variable = ObservableValue(value)
            weakVariable = variable
            XCTAssertNotNil(weakVariable)
            observation = variable.observe { _ in }
            XCTAssertNotNil(observation)
            thenVariable(variable, equals: value)
        }
        
        // sicne a strong reference to the observation exists, the Variable is retained
        XCTAssertNotNil(observation)
        XCTAssertNotNil(weakVariable)
        
        // when the reference to the observation is removed, the Variable is released
        observation = nil
        XCTAssertNil(weakVariable)
    }
    
    func testRetainDisposable() {
        let value = singleValue()
        weak var weakVariable: ObservableValue<ValueType>?
        var disposable: Disposable?
        do {
            let variable = ObservableValue(value)
            weakVariable = variable
            XCTAssertNotNil(weakVariable)
            disposable = variable.observe { _ in }.disposable
            XCTAssertNotNil(disposable)
            thenVariable(variable, equals: value)
        }
        
        // when keeping an observation, variable is retained
        XCTAssertNotNil(disposable)
        XCTAssertNotNil(weakVariable)
        
        // when the observation is removed, variable is released
        disposable = nil
        XCTAssertNil(weakVariable)
    }
    
    //MARK: Map
    
    func testMapValue() {
        let (value1, value2) = differentValues()
        
        let variable = ObservableValue(value1)
        thenVariable(variable, equals: value1)
        
        let mapped = variable.map { $0 + $0 }
        XCTAssertNotEqual(value1, value1 + value1)
        thenVariable(variable, equals: value1)
        thenObservableValue(mapped, equals: value1 + value1)
        
        variable.value = value2
        XCTAssertNotEqual(value2, value2 + value2)
        thenVariable(variable, equals: value2)
        thenObservableValue(mapped, equals: value2 + value2)
    }
    
    func testMapObservation() {
        // given two different values and a Variable
        let (value1, value2) = differentValues()
        let variable = ObservableValue(value1, validate: {_,_ in true })
        var observation: Observation?
        
        do {
            let mapped = variable.map { $0 + $0 }
            observation = whenObserving(mapped)
        }
        
        givenNoCalls()
        variable.value = value2
        thenBlockIsCalled()
        
        observation?.remove()
    }
    
    func testRetainMapped() {
        let value = singleValue()
        // given a weak reference to a Variable, a weak reference to an observable and
        // a strong reference to an observation
        weak var weakVariable: ObservableValue<ValueType>?
        var mappedObservation: Observation?
        weak var weakMappedObservable: Observable<ValueType>?
        
        // when creating a Variable and mapping it, assigning the resulting observable
        // to a weak reference, observing the mapped observable and assigning the
        // observation to the strong reference
        do {
            let variable = ObservableValue(value)
            weakVariable = variable
            XCTAssertNotNil(weakVariable)
            
            let mapped = variable.map { $0 + $0 }
            weakMappedObservable = mapped
            XCTAssertNotNil(weakMappedObservable)
            
            mappedObservation = mapped.observe { _ in }
            XCTAssertNotNil(mappedObservation)
            
            thenVariable(variable, equals: value)
        }
        
        // since a strong reference to the observation on the mapped observable
        // exists, the Variable is retained
        XCTAssertNotNil(mappedObservation)
        XCTAssertNotNil(weakMappedObservable)
        XCTAssertNotNil(weakVariable)
        
        // when the observation is removed, the Variable is released
        mappedObservation?.remove()
        XCTAssertNil(weakMappedObservable)
        XCTAssertNil(weakVariable)
    }
    
    //MARK: Combine
    
    func testCombineValue() {
        let (value1, value2) = differentValues()
        
        let variable1 = ObservableValue(value1)
        let variable2 = ObservableValue(value2)
        
        let combined = variable1.combine(variable2)
        thenObservableValue(combined, equals: (value1, value2))
        
        variable1.value = value2
        thenObservableValue(combined, equals: (value2, value2))
    }
    
    func testCombineObservation() {
        let (value1, value2) = differentValues()
        
        let variable1 = ObservableValue(value1, validate: {_,_ in true })
        let variable2 = ObservableValue(value2, validate: {_,_ in true })
        var observation: Observation?
        
        do {
            let combined = variable1.combine(variable2)
            observation = whenObserving(combined)
        }
        
        givenNoCalls()
        variable1.value = value2
        thenBlockIsCalled()
        
        givenNoCalls()
        variable2.value = value1
        thenBlockIsCalled()
        
        observation?.remove()
    }
    
    func testFlatMapValue() {
        let (value1, value2, value3) = differentValues3()
        
        let source = ObservableValue(true)
        let variable1 = ObservableValue(value1)
        let variable2 = ObservableValue(value2)
        
        let mapped = source.flatMap { bool in
            bool ? variable1 : variable2
        }
        let observation = whenObserving(mapped)
        
        // the mapped value matches `variable1`
        thenObservableValue(mapped, equals: value1)

        // when changing the source's value, the mapped value matches `variable2`
        givenNoCalls()
        source.value = false
        thenObservableValue(mapped, equals: value2)
        thenBlockIsCalled()
        
        // when changing the source's value back, the mapped value matches `variable1`
        givenNoCalls()
        source.value = true
        thenObservableValue(mapped, equals: value1)
        thenBlockIsCalled()
        
        // when changing the value of `variable1`, the mapped value is updated
        givenNoCalls()
        variable1.value = value3
        thenObservableValue(mapped, equals: value3)
        thenBlockIsCalled()
        
        // when changing the source's value, the mapped value matches `variable2`
        givenNoCalls()
        source.value = false
        thenObservableValue(mapped, equals: value2)
        thenBlockIsCalled()
        
        // when changing the value of `variable1`, the mapped value is not updated
        givenNoCalls()
        variable1.value = value1
        thenObservableValue(mapped, equals: value2)
        thenBlockIsNotCalled()
        
        observation.remove()
    }
    
    func testFlatMapRetain() {
        let (value1, value2) = differentValues()
        
        weak var weakVariable1: ObservableValue<ValueType>?
        weak var weakVariable2: ObservableValue<ValueType>?
        weak var weakMapped: Observable<ValueType>?
        var observation: Observation?
        
        do {
            let variable1 = ObservableValue(value1, validate: {_,_ in true })
            let variable2 = ObservableValue(value2, validate: {_,_ in true })
            
            weakVariable1 = variable1
            XCTAssertNotNil(weakVariable1)
            
            weakVariable2 = variable2
            XCTAssertNotNil(weakVariable2)
            
            let mapped = variable1.flatMap { _ in
                variable2
            }
            
            weakMapped = mapped
            XCTAssertNotNil(weakMapped)
            
            observation = whenObserving(mapped)
            XCTAssertNotNil(observation)
            
            thenVariable(variable1, equals: value1)
            thenVariable(variable2, equals: value2)
            thenObservableValue(mapped, equals: value2)
        }
        XCTAssertNotNil(weakVariable1)
        XCTAssertNotNil(weakVariable2)
        XCTAssertNotNil(weakMapped)
        
        observation?.remove()
        XCTAssertNil(weakVariable1)
        XCTAssertNil(weakVariable2)
        XCTAssertNil(weakMapped)
    }
    /*
    func testCachingRetain() {
        let value = singleValue()
        
        weak var weakVariable: Variable<ValueType>?
        var strongVariable: Variable<ValueType>?
        weak var weakCached: Observable<ValueType>?
        var observation: Observation?
        
        do {
            let variable = Variable(value, validate: {_,_ in true })
            weakVariable = variable
            strongVariable = variable
            XCTAssertNotNil(weakVariable)
            XCTAssertNotNil(strongVariable)
            
            let cached = Observable(caching: variable)
            weakCached = cached
            XCTAssertNotNil(weakCached)
            
            observation = whenObserving(cached)
            XCTAssertNotNil(observation)
            
            thenVariable(variable, equals: value)
            thenObservableValue(cached, equals: value)
        }
        XCTAssertNotNil(observation)
        XCTAssertNotNil(strongVariable)
        XCTAssertNotNil(weakVariable)
        XCTAssertNotNil(weakCached)
        thenObservableValue(weakCached!, equals: value)
        
        strongVariable = nil
        XCTAssertNil(weakVariable)
        XCTAssertNotNil(weakCached)
        thenObservableValue(weakCached!, equals: value)
        
        observation?.remove()
        XCTAssertNil(weakVariable)
        XCTAssertNil(weakCached)
    }
    
    func testCachingRetainMapped() {
        let value = singleValue()
        
        weak var weakVariable: Variable<ValueType>?
        weak var weakCached: Observable<ValueType>?
        weak var weakMapped: Observable<ValueType>?
        var observation: Observation?
        
        do {
            let variable = Variable(value, validate: {_,_ in true })
            weakVariable = variable
            XCTAssertNotNil(weakVariable)
            
            let mapped = variable.map { $0 + $0 }
            weakMapped = mapped
            XCTAssertNotNil(weakMapped)
            
            let cached = Observable(caching: mapped)
            weakCached = cached
            XCTAssertNotNil(weakCached)
            
            observation = whenObserving(cached)
            XCTAssertNotNil(observation)
            
            thenVariable(variable, equals: value)
            thenObservableValue(mapped, equals: value + value)
            thenObservableValue(cached, equals: value + value)
            XCTAssertNotEqual(value, value + value)
        }
        XCTAssertNotNil(observation)
        XCTAssertNil(weakVariable)
        XCTAssertNil(weakMapped)
        XCTAssertNotNil(weakCached)
        thenObservableValue(weakCached!, equals: value + value)
        
        observation?.remove()
        XCTAssertNil(weakVariable)
        XCTAssertNil(weakMapped)
        XCTAssertNil(weakCached)
    }
    
    func testCachingWeakMappedValue() {
        let (value1, value2) = differentValues()
        
        XCTAssertNotEqual(value1, value1 + value1)
        XCTAssertNotEqual(value1, value2 + value2)
        
        let variable = Variable(value1)
        var strongMapped: Observable<ValueType>?
        var cached: Observable<ValueType>?

        do {
            let mapped = variable.map { $0 + $0 }
            strongMapped = mapped
            
            cached = Observable(caching: mapped)
        }
        
        // The cached and mapped observables have the expected values
        thenVariable(variable, equals: value1)
        XCTAssertNotNil(strongMapped)
        thenObservableValue(strongMapped!, equals: value1 + value1)
        XCTAssertNotNil(cached)
        thenObservableValue(cached!, equals: value1 + value1)
        
        // When updating the variable, the cached value is updated
        variable.value = value2
        XCTAssertNotNil(strongMapped)
        thenObservableValue(strongMapped!, equals: value2 + value2)
        XCTAssertNotNil(cached)
        thenObservableValue(cached!, equals: value2 + value2)

        // After removing the strong reference to the mapped observable,
        // when updating the variable, the cached value is not updated
        strongMapped = nil
        variable.value = value1
        XCTAssertNotNil(cached)
        thenObservableValue(cached!, equals: value2 + value2)
    }
    */
    //MARK: Helpers
    
    func singleValue() -> ValueType {
        return "single value"
    }
    
    func differentValues() -> (ValueType, ValueType) {
        let value1 = "value 1"
        let value2 = "value 2"
        XCTAssert(value1 != value2)
        return (value1, value2)
    }
    
    func differentValues3() -> (ValueType, ValueType, ValueType) {
        let (value1, value2) = differentValues()
        let value3 = "value 3"
        XCTAssert(value3 != value1)
        XCTAssert(value3 != value2)
        return (value1, value2, value3)
    }
    
    func differentOptionalValues() -> (ValueType?, ValueType?) {
        let values = differentValues()
        return (values.0, values.1)
    }
}
