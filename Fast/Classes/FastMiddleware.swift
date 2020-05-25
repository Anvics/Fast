//
//  FastMiddleware.swift
//  AmberPlayground
//
//  Created by Nikita Arkhipov on 22.01.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import Foundation

public typealias EmptyClosure = () -> Void

public protocol FastMiddleware {
    func preprocess()
    
    func process(router: FastRouter, complete: EmptyClosure)
    
    func postprocess()
}

extension FastMiddleware{
    func preprocess(){}
    
    func process(router: FastRouter, complete: EmptyClosure){ complete() }
    
    func postprocess(){}
}

