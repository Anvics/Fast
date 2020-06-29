//
//  LabelComponent.swift
//  Bond
//
//  Created by Nikita Arkhipov on 04.02.2020.
//

import UIKit
import ReactiveKit
import Bond

public class LabelData: FastDataCreatable, Equatable{
    let text: String?
    let textColor: UIColor?
    let font: UIFont?
    let viewData: ViewData?

    required public init(data: String?){
        self.text = data
        self.textColor = nil
        self.font = nil
        self.viewData = nil
    }
 
    public init(text: String? = nil, textColor: UIColor? = nil, font: UIFont? = nil, backgroundColor: UIColor? = nil, alpha: CGFloat? = nil, isHidden: Bool? = nil) {
        self.text = text
        self.textColor = textColor
        self.font = font
        self.viewData = ViewData(backgroundColor: backgroundColor, alpha: alpha, isHidden: isHidden)
    }
}

public func ==(left: LabelData, right: LabelData) -> Bool{
    return left.text == right.text &&
        left.textColor == right.textColor &&
        left.font == right.font &&
        left.viewData == right.viewData
}

extension UILabel: FastComponent{
    public typealias Data = LabelData
    public var event: SafeSignal<Void> { SafeSignal(just: ()) }
    
    public func update(data: LabelData) {
        resolve(data.text) { text = $0 }
        resolve(data.textColor) { textColor = $0 }
        resolve(data.font) { font = $0 }
        baseUpdate(with: data.viewData)
    }
}
