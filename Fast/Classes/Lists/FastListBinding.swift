//
//  FastListBinding.swift
//  Fast
//
//  Created by Nikita Arkhipov on 06.02.2020.
//

import UIKit
import ReactiveKit
import Bond

public class FastListBinding<S, Model, Cell: NSObject, Action, LC: FastListConnector<Model, Cell, Action>>: FastBinding<S, Action>{
    typealias Extractor = (S) -> [Model]
    typealias ActionProvider = (Int) -> Action?

    let extractor: Extractor
    let connector: LC
    var cellAction: ActionProvider?

    init(extractor: @escaping Extractor, connector: LC) {
        self.extractor = extractor
        self.connector = connector
    }

    public override func setup(state: Property<S>, reduce: Subject<Action, Never>) {
        connector.reducer = reduce
        _ = state.map(extractor).observeNext(with: connector.updateItems)
        if let action = cellAction{
            connector.cellPressed = { i in
                if let a = action(i){ reduce.next(a) }
            }
        }
    }
}

public class FastSectionListBinding<S, Model, SubModel, Cell: NSObject, SubCell: NSObject, Action, LC: FastListSectionConnector<Model, SubModel, Cell, SubCell, Action>>: FastListBinding<S, Model, Cell, Action, LC>{
    
    typealias SubitemActionProvider = (FastIndexPath) -> Action?
    var subitemsAction: SubitemActionProvider?
    
    public override func setup(state: Property<S>, reduce: Subject<Action, Never>) {
        super.setup(state: state, reduce: reduce)
        if let action = subitemsAction{
            connector.subitemPressed = { i in
                if let a = action(i){ reduce.next(a) }
            }
        }
    }
}

public typealias FLBinding<S, Model, Cell: NSObject, Action> = FastListBinding<S, Model, Cell, Action, FastListConnector<Model, Cell, Action>>

public typealias FSLBinding<S, Model, SubModel, Cell: NSObject, SubCell: NSObject, Action> = FastSectionListBinding<S, Model, SubModel, Cell, SubCell, Action, FastListSectionConnector<Model, SubModel, Cell, SubCell, Action>>

//Create binding: Data -> Connector
public func *><S, Model, Cell: NSObject, Action>(left: @escaping (S) -> [Model], right: FastListConnector<Model, Cell, Action>) -> FLBinding<S, Model, Cell, Action>{
    return FastListBinding(extractor: left, connector: right)
}

public func *><S, Model, SubModel, Cell: NSObject, SubCell: NSObject, Action>(left: @escaping (S) -> [Model], right: FastListSectionConnector<Model, SubModel, Cell, SubCell, Action>) -> FSLBinding<S, Model, SubModel, Cell, SubCell, Action>{
    return FastSectionListBinding(extractor: left, connector: right)
}

//Create full binding: ListBinding -> Action
public func *><S, Model, Cell: NSObject, Action>(left: FLBinding<S, Model, Cell, Action>, right: @escaping (Int) -> Action?) -> FastBinding<S, Action>{
    left.cellAction = right
    return left
}

public func *><S, Model, SubModel, Cell: NSObject, SubCell: NSObject, Action>(left: FSLBinding<S, Model, SubModel, Cell, SubCell, Action>, right: ((Int) -> Action?, (FastIndexPath) -> Action?)) -> FastBinding<S, Action>{
    left.cellAction = right.0
    left.subitemsAction = right.1
    return left
}
