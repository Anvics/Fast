//
//  FastBinder.swift
//  Bond
//
//  Created by Nikita Arkhipov on 03.02.2020.
//

import UIKit
import ReactiveKit
import Bond

public class FastBinding<S, A>{
    public func setup(state: Property<S>, reduce: Subject<A, Never>) { }
    public func set(animation: FastAnimation) { }
    
    public func bindings() -> FastBindings<S, A>{ return FastBindings(self) }
}

public class FastBaseComponentBinding<S, C: FastBaseComponent, A>: FastBinding<S, A>{
    typealias Extractor = (S) -> C.BaseData?
    
    let extractor: Extractor?
    let component: C

    init(extractor: Extractor?, component: C) {
        self.extractor = extractor
        self.component = component
    }

    public override func set(animation: FastAnimation) {
        if component.animation != nil { return }
        component.animation = animation
    }
    
    public override func setup(state: Property<S>, reduce: Subject<A, Never>) {
        if let extractor = extractor{
            let animation = component.animation ?? NoAnimation()
            _ = state.map(extractor).ignoreNils().removeDuplicates().observeNext(with: animation.with(component.baseUpdate))
        }
    }
}

public class FastComponentBinding<S, C: FastComponent, A>: FastBinding<S, A>{
    typealias Extractor = (S) -> C.Data?
    typealias ActionProvider = (C.Signal.Element) -> A?

    let extractor: Extractor?
    let component: C
    var action: ActionProvider?
    
    init(extractor: Extractor?, component: C) {
        self.extractor = extractor
        self.component = component
    }
    
    init(component: C, action: @escaping ActionProvider) {
        self.extractor = nil
        self.component = component
        self.action = action
    }
    
    public override func set(animation: FastAnimation) {
        if component.animation != nil { return }
        component.animation = animation
    }
    
    public override func setup(state: Property<S>, reduce: Subject<A, Never>) {
        if let extractor = extractor{
            let animation = component.animation ?? NoAnimation()
            _ = state.map(extractor).ignoreNils().removeDuplicates().observeNext(with: animation.with(component.update))
        }
        if let action = action{
            component.event.map(action).ignoreNils().bind(to: reduce)
        }
    }
}

public extension Array{
    func bindings<S, A>() -> FastBindings<S, A> where Element == FastBinding<S, A>{
        return FastBindings(self)
    }
}

public class FastBindings<S, A> {
    let bindings: [FastBinding<S, A>]
    
    public init(){
        self.bindings = []
    }
    
    public init(_ bindings: [FastBinding<S, A>]){
        self.bindings = bindings
    }
    
    public init(_ bindings: FastBinding<S, A>...){
        self.bindings = bindings
    }
    
    func setup(store: FastStore<S, A>){
        bindings.forEach { $0.setup(state: store.state, reduce: store.reducer) }
    }
    
    public func with(_ animation: FastAnimation) -> FastBindings<S, A>{
        bindings.forEach { $0.set(animation: animation) }
        return self
    }
}

public func +<S, A>(left: FastBinding<S, A>, right: FastBinding<S, A>) -> FastBindings<S, A>{
    return FastBindings([left, right])
}

public func +<S, A>(left: FastBindings<S, A>, right: FastBinding<S, A>) -> FastBindings<S, A>{
    return FastBindings(left.bindings + [right])
}

public func +<S, A>(left: FastBindings<S, A>, right: FastBindings<S, A>) -> FastBindings<S, A>{
    return FastBindings(left.bindings + right.bindings)
}

infix operator *>: MultiplicationPrecedence

//Create binding Data -> BaseComponent
public func *><S, C: FastBaseComponent, A>(left: @escaping (S) -> C.BaseData?, right: C) -> FastBaseComponentBinding<S, C, A>{
    return FastBaseComponentBinding(extractor: left, component: right)
}

public func *><S, C: FastBaseComponent, A>(left: @escaping (S) -> C.BaseData.Data?, right: C) -> FastBaseComponentBinding<S, C, A> where C.BaseData: FastDataCreatable{
    return FastBaseComponentBinding(extractor: { C.BaseData(data: left($0)) }, component: right)
}

//Create binding Data -> Component
public func *><S, C: FastComponent, A>(left: @escaping (S) -> C.Data?, right: C) -> FastComponentBinding<S, C, A>{
    return FastComponentBinding(extractor: left, component: right)
}

public func *><S, C: FastComponent, A>(left: @escaping (S) -> C.Data.Data?, right: C) -> FastComponentBinding<S, C, A> where C.Data: FastDataCreatable{
    return FastComponentBinding(extractor: { C.Data(data: left($0)) }, component: right)
}

//Create binding Component -> Action
public func *><S, C: FastComponent, A>(left: C, right: @escaping (C.Signal.Element) -> A?) -> FastBinding<S, A>{
    return FastComponentBinding(component: left, action: right)
}

public func *><S, C: FastComponent, A>(left: C, right: A) -> FastBinding<S, A>{
    return FastComponentBinding(component: left, action: { _ in right })
}

//Create full binding (Data -> Component) -> Action
public func *><S, C: FastComponent, A>(left: FastComponentBinding<S, C, A>, right: @escaping (C.Signal.Element) -> A?) -> FastBinding<S, A>{
    left.action = right
    return left
}

public func *><S, C: FastComponent, A>(left: FastComponentBinding<S, C, A>, right: A) -> FastBinding<S, A>{
    left.action = { _ in right }
    return left
}


//Dynamic actions
public protocol FastDynamicAction{
    associatedtype State
    
    static func dynamic(changeState: @escaping (inout State) -> Void) -> Self
}


infix operator **>: MultiplicationPrecedence

public func **><S, C: FastComponent, A>(left: C, right: @escaping (inout S, C.Signal.Element) -> Void) -> FastBinding<S, A> where A: FastDynamicAction, S == A.State{
    return FastComponentBinding(component: left, action: { e in A.dynamic { s in right(&s, e) } })
}

public func **><S, C: FastComponent, A>(left: C, right: @escaping (inout S) -> Void) -> FastBinding<S, A> where A: FastDynamicAction, S == A.State, C.Signal.Element == Void{
    return FastComponentBinding(component: left, action: { _ in A.dynamic { s in right(&s) } })
}

public func *><S, C: FastComponent, A>(left: FastComponentBinding<S, C, A>, right: @escaping (inout S, C.Signal.Element) -> Void) -> FastBinding<S, A> where A: FastDynamicAction, S == A.State{
    left.action = { e in A.dynamic { s in right(&s, e) } }
    return left
}

public func *><S, C: FastComponent, A>(left: FastComponentBinding<S, C, A>, right: @escaping (inout S) -> Void) -> FastBinding<S, A> where A: FastDynamicAction, S == A.State, C.Signal.Element == Void{
    left.action = { _ in A.dynamic { s in right(&s) } }
    return left
}
