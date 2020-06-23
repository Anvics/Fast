//
//  FastStore.swift
//  AmberPlayground
//
//  Created by Nikita Arkhipov on 22.01.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import Foundation
import UIKit
import ReactiveKit

public protocol FastState {
    associatedtype RequiredData
    init(data: RequiredData)
}

public class FastStore<State, Action>{
    public let state: Property<State>
    public let reducer = SafeReplayOneSubject<Action>()
    public let router: FastRouter
    
    public let didAppeared: () -> Void
    public let deinitialize: () -> Void

    private let reduceAction: (Action) -> Void
    
    init<InputAction, OutputAction>(performer: FastStorePerformer<State, Action, InputAction, OutputAction>){
        state = performer.state
        router = performer.actor
        didAppeared = performer.didAppeared
        deinitialize = performer.deinitalize
        reduceAction = performer.reduce
        subscribe()
    }
    
    func reduce(action: Action){
        reduceAction(action)
    }
    
    func subscribe(){
        let _ = reducer.observeNext { [weak self] in self?.reduce(action: $0) }
    }
}

public class FastStorePerformer<State, Action, InputAction, OutputAction>{
    let state: Property<State>
    
    var outputListener: ((OutputAction) -> Void)?

    weak var rootController: UIViewController?
    weak var controller: UIViewController?

    typealias Actor = FastActor<Action, InputAction, OutputAction>
    typealias Reducer = FastReducerWrapper<State, Action, InputAction, OutputAction>
    
    private var reducer: Reducer
    
    var updateState: (State, State) -> Void = { _, _ in }

    lazy var actor: Actor = { Actor(rootController: rootController, controller: controller, reducer: reduce, inputReducer: inputReduce, outputReducer: outputReduce) }()

    init(state: State, reducer: Reducer, rootController: UIViewController?, controller: UIViewController, outputListener: ((OutputAction) -> Void)?){
        self.state = Property(state)
        self.reducer = reducer
        self.rootController = rootController
        self.controller = controller
        self.outputListener = outputListener
        
        reducer.initialize(state, actor)
    }

    private func performReduction<A>(action: A, provider: (State, A, Actor) -> [FastMiddleware], reducer: @escaping (State, A, Actor) -> State?){
        Fast.toggled(action: action)
        let m = provider(state.value, action, actor)

        func complete(){
            if let s = reducer(state.value, action, actor){
                let oldValue = state.value
                state.value = s
                m.forEach { $0.postprocess() }
                updateState(oldValue, s)
            }
        }

        func processAt(index: Int){
            if index == m.count { complete(); return }
            m[index].process(router: actor) { processAt(index: index + 1) }
        }

        m.forEach { $0.preprocess() }
        processAt(index: 0)
    }

    func reduce(action: Action){
        performReduction(action: action, provider: reducer.middleware, reducer: reducer.reduce)
    }

    func inputReduce(action: InputAction){
        performReduction(action: action, provider: { _, _, _ in [] }, reducer: reducer.reduceInput)
    }

    private func outputReduce(action: OutputAction){
        outputListener?(action)
    }
    
    func wrapped() -> FastStore<State, Action>{
        return FastStore(performer: self)
    }
    
    func didAppeared(){
        if let s = reducer.didAppeared(state.value, actor){ state.value = s }
    }
    
    func deinitalize(){
        reducer.deinitialize()
    }
}


