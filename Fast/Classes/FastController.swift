//
//  FastController.swift
//  AmberPlayground
//
//  Created by Nikita Arkhipov on 22.01.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

public protocol FastStoreSetupable {
    var view: UIView! { get }
    
    func set<S, A>(store: FastStore<S, A>)
    func setupBindings()
    
    func updateStateListener<S>() -> (S, S) -> Void
}

public protocol FastController: class, FastStoreSetupable {
    associatedtype State
    associatedtype Action
    
    typealias Binds = FastBindings<State, Action>
    
    var store: FastStore<State, Action>! { get set }
    var bindings: Binds { get }
    
    func stateUpdated(from: State, to: State)
}

public extension FastController{
    var bindings: Binds { Binds() }
    
    func set<S, A>(store: FastStore<S, A>){
        guard let s = store as? FastStore<State, Action> else { fatalError("\(type(of: self)) failed to set store: expected <\(State.self), \(Action.self)> got <\(S.self), \(A.self)>") }
        self.store = s
    }
    
    func setupBindings() {
        bindings.setup(store: store)
    }
    
    func stateUpdated(from: State, to: State){ }
    
    func updateStateListener<S>() -> (S, S) -> Void {
        return { [weak self] s1, s2 in
            guard let s1 = s1 as? State, let s2 = s2 as? State else { fatalError() }
            self?.stateUpdated(from: s1, to: s2)
        }
    }
}

public extension FastController where Self: UIViewController{
    func initialize<C: FastConfigurator>(configurator: C, data: C.RequiredData) where C.State == State, C.Action == Action{
        store = configurator.store(data: data, controller: self).wrapped()
        _ = view//hack to force load view
        setupBindings()
    }
    
    func initialize<C: FastConfigurator>(configurator: C) where C.RequiredData == Void, C.State == State, C.Action == Action{
        initialize(configurator: configurator, data: ())
    }
}

public extension FastController{
    var reduce: Subject<Action, Never> { return store.reducer }
    var state: State { return store.state.value }
    
    func field<T: Equatable>(_ extractor: @escaping (State) -> T) -> Signal<T, Never>{
        return store.state.map(extractor).removeDuplicates()
    }
    
    func reduce(action: Action){
        store.reduce(action: action)
    }
    
    func component<Module: FastConfigurator>(module: Module.Type, data: Module.RequiredData, transition: FastTransitionType) -> FastModuleComponent<Module>{
        let component = FastModuleComponent(module: module)
        component.input = store.router.route(module, data: data, transition: transition, animated: true, outputListener: component.event.next).inputActionListener
        return component
    }
}

private var UIView_Associated_Embeded: UInt8 = 0
extension UIView{
    var embedded: [UIViewController]{
        get {
            return objc_getAssociatedObject(self, &UIView_Associated_Embeded) as? [UIViewController] ?? []
        }
        set {
            objc_setAssociatedObject(self, &UIView_Associated_Embeded, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func unembedAll(){
        embedded.forEach { $0.unembed(shouldModifyEmbedArray: false) }
        embedded = []
    }
}

extension UIViewController{
    public func push(_ viewController: UIViewController, animated: Bool){
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    public func embed(in view: UIView, container: UIViewController, clean: Bool = false){
        if clean { view.unembedAll() }
        self.view.frame = view.bounds
        container.addChild(self)
        view.addSubview(self.view)
        view.embedded.append(self)
        didMove(toParent: container)
    }


    public func embedIn(view: UIView, container: UIViewController){
        self.view.frame = view.bounds
        container.addChild(self)
        view.addSubview(self.view)
        view.embedded.append(self)
        didMove(toParent: container)
    }
    
    public func show(_ viewController: UIViewController, animated: Bool){
        if navigationController != nil { push(viewController, animated: true) }
        else { present(viewController, animated: true, completion: nil) }
    }
    
    public func close(animated: Bool){
        if let nav = navigationController{ nav.popViewController(animated: animated) }
        else if parent != nil { unembed() }
        else{ dismiss(animated: animated, completion: nil) }
    }
    
    public func dismiss(animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }
    
    public func pop(animated: Bool){
        navigationController?.popViewController(animated: animated)
    }
    
    public func popToRoot(animated: Bool){
        navigationController?.popToRootViewController(animated: animated)
    }
    
    public func unembed(shouldModifyEmbedArray: Bool = true){
        removeFromParent()
        if let index = view.superview?.embedded.firstIndex(of: self), shouldModifyEmbedArray{
            view.superview?.embedded.remove(at: index)
        }
        view.removeFromSuperview()
        didMove(toParent: nil)
    }
    
    public func replaceWith(_ vc: UIViewController, animation: UIView.AnimationOptions){
        guard let currentVC = UIApplication.shared.keyWindow?.rootViewController else { fatalError() }
        UIView.transition(from: currentVC.view, to: vc.view, duration: 0.4, options: animation) { _ in
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
    }
}
