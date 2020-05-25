//
//  Fast.swift
//  AmberPlayground
//
//  Created by Nikita Arkhipov on 22.01.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit

public class Fast{
    public static var shouldLogActions = true
    
    static func toggled(action: Any){
        if !shouldLogActions { return }
        print("-----------------------------")
        print("\(type(of: action)).\(action)")
    }
    
    public static func setInitial(controller: UIViewController, window: UIWindow){
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
    
    public static func setInitial(controller: FastLink, window: UIWindow!){
        setInitial(controller: controller.instantiate(), window: window)
    }
    
    public static func setInitial<Module: FastConfigurator>(module: Module.Type, data: Module.RequiredData, window: UIWindow!){
        setInitial(controller: Module().create(data: data).controller, window: window)
    }

    public static func setInitial<Module: FastConfigurator>(module: Module.Type, window: UIWindow!) where Module.RequiredData == Void{
        setInitial(controller: Module().create().controller, window: window)
    }

    
//    private static var simulatedActions: [SimulatedActionType] = []
//
//    public static func setInitial(){
//
//    }
//
//    public static func simulate(actions: [SimulatedActionType]){
//        simulatedActions = actions
//    }
//
//    static func moduleInitialized<Module: FastModule>(module: Module){
//        simulatedActions = simulatedActions.filter { $0.isProcessed(module: module) }
//    }
}
