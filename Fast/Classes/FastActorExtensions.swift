//
//  FastActorExtensions.swift
//  FastArchitecture
//
//  Created by Nikita Arkhipov on 23.09.2020.
//

import Bond
import ReactiveKit

public extension FastActor{
    func reduce(_ action: Action, delay: TimeInterval){
        Fast_Delay(delay) { self.reduce(action) }
    }
    
    func repeatAction(_ action: Action, every: TimeInterval){
        reduce(action)
        Fast_Delay(every) { [weak self] in self?.repeatAction(action, every: every) }
    }
    
    func bind<S: SignalProtocol>(event: S, to action: Action, skipFirst: Bool = false, removeDuplicates: Bool = true) where S.Element: Equatable{
        var signal: Signal<S.Element, S.Error> = event.toSignal()
        if removeDuplicates { signal = signal.removeDuplicates() }
        if skipFirst { signal = signal.dropFirst(1) }
        _ = signal.observeNext { [weak self] _ in self?.reduce(action) }
    }
}

public extension FastActor where Action: FastDynamicAction{
    func update(){
        reduce(Action.dynamic(changeState: { _ in }))
    }
    
    func update(state: @escaping (inout Action.State) -> Void){
        reduce(Action.dynamic(changeState: state))
    }
    
    func updateState(){
        reduce(Action.dynamic(changeState: { _ in }))
    }
    
    func update(after: TimeInterval, state: @escaping (inout Action.State) -> Void){
        Fast_Delay(after) { self.reduce(Action.dynamic(changeState: state)) }
    }
    
    func bind<S: SignalProtocol>(_ signal: S, to keyPath: WritableKeyPath<Action.State, S.Element>, delay: TimeInterval? = nil) where S.Element: Equatable{
        var resultSignal = signal.removeDuplicates()
        if let delay = delay { resultSignal = resultSignal.delay(interval: delay, on: .main) }
        
        _ = resultSignal.observeNext { [weak self] v in
            precondition(self != nil)
            self?.reduce(Action.dynamic(changeState: { $0[keyPath: keyPath] = v }))
        }
    }
}

public func Fast_Delay(_ seconds: Double, perform: @escaping () -> ()){
    let delayTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
        perform()
    }
}

public func Fast_OnMain(perform: @escaping () -> ()){
    DispatchQueue.main.async(execute: perform)
}

public func Fast_OnBackground(perform: @escaping () -> ()){
    DispatchQueue.global().async(execute: perform)
}
