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
    let frame: CGRect?
    
    ///data = isVisible
    required public init(data: Bool?){
        self.backgroundColor = nil
        self.alpha = data?.cgfloat
        self.isHidden = nil
        self.frame = nil
    }
    
    public init(backgroundColor: UIColor? = nil, alpha: CGFloat? = nil, isHidden: Bool? = nil, frame: CGRect? = nil) {
        self.backgroundColor = backgroundColor
        self.alpha = alpha
        self.isHidden = isHidden
        self.frame = frame
    }
}

public func ==(left: ViewData, right: ViewData) -> Bool{
    return left.backgroundColor == right.backgroundColor &&
        left.isHidden == right.isHidden &&
        left.alpha == right.alpha
}

extension UIView: FastBaseComponent{
    public func baseUpdate(data: ViewData) {
        resolve(data.backgroundColor) { backgroundColor = $0 }
        resolve(data.alpha) { alpha = $0 }
        resolve(data.isHidden) { isHidden = $0 }
        resolve(data.frame) { frame = $0 }
    }
    
    public func baseUpdate(with: ViewData?){
        if let d = with { baseUpdate(data: d) }
    }
}

extension Bool{
    var cgfloat: CGFloat{ self ? 1 : 0 }
}
