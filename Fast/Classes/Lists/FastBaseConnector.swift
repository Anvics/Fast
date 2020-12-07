//
//  File.swift
//  FastArchitecture
//
//  Created by Nikita Arkhipov on 04.12.2020.
//

import Foundation
import ReactiveKit
import Bond

public struct FastIndexPath{
    let item: Int
    let section: Int
}

public extension FastIndexPath{
    init(item: Int) {
        self.item = item
        self.section = 0
    }
    
    var tablePath: IndexPath{ IndexPath(row: item, section: section) }
    var collectionPath: IndexPath { IndexPath(item: item, section: section) }
}

public extension IndexPath{
    var tablePath: FastIndexPath { FastIndexPath(item: row, section: section) }
    var collectionPath: FastIndexPath{ FastIndexPath(item: item, section: section) }
}

public class FastListConnector<Model, Cell: NSObject, Action>: NSObject{
    public typealias Reducer = Subject<Action, Never>
    public typealias CellUpdateBlock = (Cell, Model, [Model], Int, Reducer) -> Void
    public typealias CellPressedListener = (Int) -> Void
    public typealias ReloadDecider = ([Model], [Model]) -> Bool
    
    let cellUpdateBlock: CellUpdateBlock
    private(set) var items: [Model] = []
    
    public let reloadListBlock: (() -> Void)
    public var reducer: Subject<Action, Never>?
    public var cellPressed: CellPressedListener?
    public var shouldReloadDeciderBlock: ReloadDecider?

    open var cellIdentifier: String{
        let name = "\(type(of: Cell.self))"
        return String(name.prefix(upTo: name.firstIndex(of: ".")!))
    }
    
    public init(implementation: FastListImplementationType, cellUpdateBlock: @escaping CellUpdateBlock) {
        self.reloadListBlock = implementation.escapingReloadBlock()
        self.cellUpdateBlock = cellUpdateBlock
        super.init()
        implementation.connector = self
    }
    
    public init(implementation: FastListImplementationType, cellUpdateBlock: @escaping CellUpdateBlock, shouldIgnoreDuplicates: Bool) where Model: Equatable {
        self.reloadListBlock = implementation.escapingReloadBlock()
        self.cellUpdateBlock = cellUpdateBlock
        super.init()
        if shouldIgnoreDuplicates {
            shouldReloadDeciderBlock = { $0 != $1 }            
        }
    }
    
    open func updateItems(with: [Model]){
        let current = items
        items = with
        reloadIfNeeded(currentItems: current, newItems: with)
    }
    
    open func reloadIfNeeded(currentItems: [Model], newItems: [Model]){
        if let reloadDecider = shouldReloadDeciderBlock, !reloadDecider(currentItems, newItems) { return }
        reload()
    }
    
    open func reload(){
        reloadListBlock()
    }
    
    open func processCellPressed(indexPath: FastIndexPath){
        cellPressed?(indexPath.item)
    }
    
    open func update(cell: Cell, indexPath: FastIndexPath, reducer: Reducer){
        cellUpdateBlock(cell, items[indexPath.item], items, indexPath.item, reducer)
    }
    
    open func extractCell(list: FastListImplementationType, indexPath: FastIndexPath) -> Cell{
        let cell: Cell = list.deque(cellIdentifier: cellIdentifier, indexPath: indexPath)
        cell.reactive.bag.dispose()
        if let reducer = reducer { update(cell: cell, indexPath: indexPath, reducer: reducer) }
        return cell
    }
}

public class FastListSectionConnector<Model, SubModel, Cell: NSObject, SubCell: NSObject, Action>: FastListConnector<Model, Cell, Action>{
    public typealias SubitemPressedListener = (FastIndexPath) -> Void
    public typealias SubItemsExtractor = (Model) -> [SubModel]
    public typealias SubCellUpdateBlock = (SubCell, SubModel, [SubModel], FastIndexPath, Reducer) -> Void
        
    public let subitemsExtractor: SubItemsExtractor
    public let subcellUpdateBlock: SubCellUpdateBlock
    public let shouldAddSectionTapListener: Bool
    
    public var subitemPressed: SubitemPressedListener?
    
    open var subcellIdentifier: String{
        let name = "\(type(of: SubCell.self))"
        return String(name.prefix(upTo: name.firstIndex(of: ".")!))
    }

    public init(implementation: FastListImplementationType, shouldAddSectionTapListener: Bool, subitemsExtractor: @escaping SubItemsExtractor, subcellUpdateBlock: @escaping SubCellUpdateBlock, cellUpdateBlock: @escaping CellUpdateBlock) {
        self.subitemsExtractor = subitemsExtractor
        self.subcellUpdateBlock = subcellUpdateBlock
        self.shouldAddSectionTapListener = shouldAddSectionTapListener
        super.init(implementation: implementation, cellUpdateBlock: cellUpdateBlock)
    }
    
    open func processSubcellPressed(indexPath: FastIndexPath){
        subitemPressed?(indexPath)
    }
    
    open func update(subcell: SubCell, indexPath: FastIndexPath, reducer: Reducer){
        let subs = subitems(in: indexPath.section)            
        subcellUpdateBlock(subcell, subs[indexPath.item], subs, indexPath, reducer)
    }
    
    open override func extractCell(list: FastListImplementationType, indexPath: FastIndexPath) -> Cell{
        let cell = super.extractCell(list: list, indexPath: indexPath)
        if !shouldAddSectionTapListener { return cell }
        (cell as? UIView)?.reactive.tapGesture().observeNext { [weak self] _ in
            self?.processCellPressed(indexPath: indexPath)
        }.dispose(in: cell.reactive.bag)
        return cell
    }
    
    open func extractSubcell(list: FastListImplementationType, indexPath: FastIndexPath) -> SubCell{
        let cell: SubCell = list.deque(cellIdentifier: subcellIdentifier, indexPath: indexPath)
        cell.reactive.bag.dispose()
        if let reducer = reducer { update(subcell: cell, indexPath: indexPath, reducer: reducer) }
        return cell
    }
    
    public func subitems(in section: Int) -> [SubModel]{
        return subitemsExtractor(items[section])
    }
}
