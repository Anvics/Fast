//
//  FastModuleConfigurator.swift
//  AmberPlayground
//
//  Created by Nikita Arkhipov on 22.01.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit

public class FastEmptyAction: Equatable{
    public init(){}
    public static func ==(lhs: FastEmptyAction, rhs: FastEmptyAction) -> Bool { true }
}

public protocol FastConfigurator {
    associatedtype RequiredData
    associatedtype State: FastState
    associatedtype Action
    associatedtype InputAction: Equatable
    associatedtype OutputAction: Equatable
    
    typealias Actor = FastActor<Action, InputAction, OutputAction>
    typealias Reducer = FastReducerWrapper<State, Action, InputAction, OutputAction>
    typealias InputActionListener = (InputAction) -> Void

    init()
            
    func reducer(data: RequiredData) -> Reducer
    func link(data: RequiredData) -> FastLink
    
    func state(data: RequiredData) -> State
}

public extension FastConfigurator{
    func store(data: RequiredData, controller: UIViewController, rootController: UIViewController? = nil, outputListener: ((OutputAction) -> Void)? = nil) -> FastStorePerformer<State, Action, InputAction, OutputAction>{
        return FastStorePerformer(state: state(data: data), reducer: reducer(data: data), rootController: rootController, controller: controller, outputListener: outputListener)
    }
    
    func create(data: RequiredData, rootController: UIViewController? = nil, outputListener: ((OutputAction) -> Void)? = nil) -> FastModuleData<InputAction>{
        let vc = link(data: data).instantiate()
        let st = store(data: data, controller: vc, rootController: rootController, outputListener: outputListener)

        guard let vcs = vc as? FastStoreSetupable else { fatalError("\(type(of: vc)) does not conforms to FastController") }
        
        vcs.set(store: st.wrapped())
        st.updateState = vcs.updateStateListener()

        _ = vc.view//hack to force load view

        vcs.setupBindings()

        return FastModuleData(controller: vc, inputActionListener: st.inputReduce)
    }
    
}

public extension FastConfigurator where State.RequiredData == RequiredData{
    func state(data: RequiredData) -> State { return State(data: data) }
}

public extension FastConfigurator where RequiredData == Void{
    func create(rootController: UIViewController? = nil, outputListener: ((OutputAction) -> Void)? = nil) -> FastModuleData<InputAction>{
        return create(data: (), rootController: rootController, outputListener: outputListener)
    }
}
