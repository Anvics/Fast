//
//  FastComponent.swift
//  Bond
//
//  Created by Nikita Arkhipov on 04.02.2020.
//

import Foundation
import ReactiveKit
import Bond

public protocol FastComponentData: Equatable {
    associatedtype Component: FastBaseComponent
    
    func update(component: Component)
}

public func resolve<T>(_ value: T?, resolver: (T) -> Void){
    if let v = value { resolver(v) }
}

public protocol FastDataCreatable {
    associatedtype Data
    init(data: Data?)
}

public protocol FastBaseComponent: NSObjectProtocol {
    associatedtype BaseData: FastComponentData where BaseData.Component == Self
}

public protocol FastComponent: FastBaseComponent {
    associatedtype Data: FastComponentData where Data.Component == Self
    associatedtype Signal: SignalProtocol where Signal.Error == Never
    var event: Signal { get }
}

struct FastComponentKeys {
    static var Animation = "Animation"
}

public extension FastBaseComponent{
    func with(_ animation: FastAnimation) -> Self{
        self.animation = animation
        return self
    }
    
    func baseUpdate(data: BaseData){
        data.update(component: self)
    }
    
    var animation: FastAnimation? {
        get {
            if let anim = objc_getAssociatedObject(self, &FastComponentKeys.Animation){ return anim as? FastAnimation }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &FastComponentKeys.Animation, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public extension FastComponent{
    func update(data: Data){
        data.update(component: self)
    }
}
