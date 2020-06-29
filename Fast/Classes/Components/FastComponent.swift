//
//  FastComponent.swift
//  Bond
//
//  Created by Nikita Arkhipov on 04.02.2020.
//

import Foundation
import ReactiveKit
import Bond

public func resolve<T>(_ value: T?, resolver: (T) -> Void){
    if let v = value { resolver(v) }
}

public protocol FastDataCreatable {
    associatedtype Data
    init(data: Data?)
}

public protocol FastBaseComponent: FastAnimatableComponent {
    associatedtype BaseData: Equatable
    
    func baseUpdate(data: BaseData)
}

public protocol FastComponent: FastAnimatableComponent {
    associatedtype Data: Equatable
    associatedtype Signal: SignalProtocol where Signal.Error == Never
    
    var event: Signal { get }
    
    func update(data: Data)
}


public class FastModuleComponent<Module: FastConfigurator>: FastComponent{
    public let event = SafeReplayOneSubject<Module.OutputAction>()
    
    typealias Input = (Module.InputAction) -> Void
    typealias Output = (Module.OutputAction) -> Void
    
    var input: Input?
    
    init(module: Module.Type) { }
    
    public func update(data: Module.InputAction) {
        input?(data)
    }
}

struct FastComponentKeys {
    static var Animation = "Animation"
}

public protocol FastAnimatableComponent: class{ }

public extension FastAnimatableComponent{
    func with(_ animation: FastAnimation) -> Self{
        self.animation = animation
        return self
    }
    
    var animation: FastAnimation? {
        get { objc_getAssociatedObject(self, &FastComponentKeys.Animation) as? FastAnimation }
        set {
            objc_setAssociatedObject(self, &FastComponentKeys.Animation, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
