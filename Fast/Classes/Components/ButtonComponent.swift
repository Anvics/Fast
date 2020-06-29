//
//  ButtonComponent.swift
//  Bond
//
//  Created by Nikita Arkhipov on 03.02.2020.
//

import UIKit
import ReactiveKit
import Bond

public class ButtonData: FastDataCreatable, Equatable {
    let title: String?
    let titleColor: UIColor?
    let image: UIImage?
    let backgroundImage: UIImage?
    let isEnabled: Bool?
    let viewData: ViewData?

    required public init(data: String?){
        self.title = data
        self.titleColor = nil
        self.image = nil
        self.backgroundImage = nil
        self.isEnabled = nil
        self.viewData = nil
    }

    public init(title: String? = nil, titleColor: UIColor? = nil, image: UIImage? = nil, backgroundImage: UIImage? = nil, isEnabled: Bool? = nil, backgroundColor: UIColor? = nil, alpha: CGFloat? = nil, isHidden: Bool? = nil) {
        self.title = title
        self.titleColor = titleColor
        self.image = image
        self.backgroundImage = backgroundImage
        self.isEnabled = isEnabled
        self.viewData = ViewData(backgroundColor: backgroundColor, alpha: alpha, isHidden: isHidden)
    }
}

public func ==(left: ButtonData, right: ButtonData) -> Bool{
    return left.title == right.title &&
        left.titleColor == right.titleColor &&
        left.image == right.image &&
        left.backgroundImage == right.backgroundImage &&
        left.isEnabled == right.isEnabled &&
        left.viewData == right.viewData
}

extension UIButton: FastComponent{
    public typealias ProducedData = Void
    public var event: SafeSignal<ProducedData> { reactive.tap }
    
    public func update(data: ButtonData) {
        resolve(data.title) { setTitle($0, for: .normal) }
        resolve(data.titleColor) { setTitleColor($0, for: .normal) }
        resolve(data.image) { setImage($0, for: .normal) }
        resolve(data.backgroundImage) { setBackgroundImage($0, for: .normal) }
        resolve(data.isEnabled) {
            isEnabled = $0
            if data.viewData?.alpha == nil { alpha = $0 ? 1 : 0.5 }
        }
        baseUpdate(with: data.viewData)
    }
}
