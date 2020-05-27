//
//  ImageComponent.swift
//  Bond
//
//  Created by Nikita Arkhipov on 04.02.2020.
//

import Foundation
import ReactiveKit
import Bond

public class ImageData: FastDataCreatable, Equatable{
    let image: UIImage?
    let viewData: ViewData?
    
    required public init(data: UIImage?){
        self.image = data
        self.viewData = nil
    }
    
    public init(image: UIImage? = nil, backgroundColor: UIColor? = nil, alpha: CGFloat? = nil, isHidden: Bool? = nil) {
        self.image = image
        self.viewData = ViewData(backgroundColor: backgroundColor, alpha: alpha, isHidden: isHidden)
    }
    
    public func update(component: UIImageView){
        let c = component
    }
}

public func ==(left: ImageData, right: ImageData) -> Bool{
    return left.image == right.image &&
        left.viewData == right.viewData
}

extension UIImageView: FastComponent{
    public var event: SafeSignal<Void> { return SafeSignal(just: ()) }
    
    public func update(data: ImageData) {
        resolve(data.image) { self.image = $0 }
        baseUpdate(with: data.viewData)
    }
}
