//
//  ImageComponent.swift
//  Bond
//
//  Created by Nikita Arkhipov on 04.02.2020.
//

import Foundation
import ReactiveKit
import Bond
import Kingfisher

public class ImageData: FastDataCreatable, Equatable{
    let image: UIImage?
    let url: URL?
    let viewData: ViewData?
    
    required public init(data: String?){
        if let value = data {
            if let image = UIImage(named: value){
                self.image = image
                self.url = nil
            }else{
                self.image = nil
                self.url = URL(string: value)
            }
        } else {
            self.image = nil
            self.url = nil
        }
        self.viewData = nil
    }
    
    public init(image: UIImage? = nil, backgroundColor: UIColor? = nil, alpha: CGFloat? = nil, isHidden: Bool? = nil) {
        self.image = image
        self.url = nil
        self.viewData = ViewData(backgroundColor: backgroundColor, alpha: alpha, isHidden: isHidden)
    }
    
    convenience public init(image: String? = nil, backgroundColor: UIColor? = nil, alpha: CGFloat? = nil, isHidden: Bool? = nil) {
        var img: UIImage? = nil
        if let name = image { img = UIImage(named: name) }
        self.init(image: img, backgroundColor: backgroundColor, alpha: alpha, isHidden: isHidden)
    }
    
    public init(url: String? = nil, backgroundColor: UIColor? = nil, alpha: CGFloat? = nil, isHidden: Bool? = nil) {
        self.image = nil
        if let vurl = url, let nurl = URL(string: vurl) { self.url = nurl }
        else { self.url = nil }
        self.viewData = ViewData(backgroundColor: backgroundColor, alpha: alpha, isHidden: isHidden)
    }
}

public func ==(left: ImageData, right: ImageData) -> Bool{
    return left.image == right.image &&
        left.viewData == right.viewData &&
        left.url == right.url
}

extension UIImageView: FastComponent{
    public var event: SafeSignal<Void> { SafeSignal(just: ()) }
    
    public func update(data: ImageData) {
        resolve(data.image) { image = $0 }
        resolve(data.url) { kf.setImage(with: $0) }
        baseUpdate(with: data.viewData)
    }
}

extension UIImage{
    public var fastData: ImageData{ ImageData(image: self) }
}
