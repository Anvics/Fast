//
//  FastReducer.swift
//  AmberPlayground
//
//  Created by Nikita Arkhipov on 22.01.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import Foundation

public protocol FastReducer {
    associatedtype State
    associatedtype Action
    associatedtype InputAction
    associatedtype OutputAction

    typealias Actor = FastActor<Action, InputAction, OutputAction>
    
    func initialize(state: State, actor: Actor)
    
    func didAppeared(state: State, actor: Actor) -> State?
    
    func deinitialize()

    func middleware(state: State, action: Action, actor: Actor) -> [FastMiddleware]

    func reduce(state: State, action: Action, actor: Actor) -> State?
    func reduceInput(state: State, action: InputAction, actor: Actor) -> State?
}

extension FastReducer{
    public func initialize(state: State, actor: Actor){ }
    
    public func didAppeared(state: State, actor: Actor) -> State? { return nil }
    
    public func deinitialize() { }
    
    public func wrapped() -> FastReducerWrapper<State, Action, InputAction, OutputAction>{
        return FastReducerWrapper(reducer: self)
    }
    
    public func middleware(state: State, action: Action, actor: Actor) -> [FastMiddleware] { return [] }
}

public class FastReducerWrapper<State, Action, InputAction, OutputAction>{
    typealias Actor = FastActor<Action, InputAction, OutputAction>
    
    let initialize: (State, Actor) -> Void
    let didAppeared: (State, Actor) -> State?
    let deinitialize: () -> Void
    
    let middleware: (State, Action, Actor) -> [FastMiddleware]

    let reduce: (State, Action, Actor) -> State?
    let reduceInput: (State, InputAction, Actor) -> State?
    
    
    init<R: FastReducer>(reducer: R) where R.State == State, R.Action == Action, R.InputAction == InputAction, R.OutputAction == OutputAction{
        initialize = reducer.initialize
        didAppeared = reducer.didAppeared
        deinitialize = reducer.deinitialize
        
        middleware = reducer.middleware

        reduce = reducer.reduce
        reduceInput = reducer.reduceInput
    }
}

