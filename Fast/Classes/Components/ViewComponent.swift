//
//  ViewComponent.swift
//  Alamofire
//
//  Created by Nikita Arkhipov on 05/02/2020.
//

import UIKit
import ReactiveKit
import Bond

public class ViewData: FastDataCreatable, Equatable{

    let backgroundColor: UIColor?
    let alpha: CGFloat?
    let isHidden: Bool?
    
    ///data = isVisible
    required public init(data: Bool?){
        self.backgroundColor = nil
        self.alpha = data?.cgfloat
        self.isHidden = nil
    }
    
    public init(backgroundColor: UIColor? = nil, alpha: CGFloat? = nil, isHidden: Bool? = nil) {
        self.backgroundColor = backgroundColor
        self.alpha = alpha
        self.isHidden = isHidden
    }
}

public func ==(left: ViewData, right: ViewData) -> Bool{
    return left.backgroundColor == right.backgroundColor &&
        left.isHidden == right.isHidden &&
        left.alpha == right.alpha
}

extension UIView: FastBaseComponent{
    public func baseUpdate(data: ViewData) {
        resolve(data.backgroundColor) { self.backgroundColor = $0 }
        resolve(data.alpha) { self.alpha = $0 }
        resolve(data.isHidden) { self.isHidden = $0 }
    }
    
    public func baseUpdate(with: ViewData?){
        if let d = with { baseUpdate(data: d) }
    }
}

extension Bool{
    var cgfloat: CGFloat{ self ? 1 : 0 }
}
