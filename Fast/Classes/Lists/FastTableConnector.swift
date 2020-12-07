//
//  FastTableConnector.swift
//  FastArchitecture
//
//  Created by Nikita Arkhipov on 04.12.2020.
//

import UIKit

public class FastTableConnector<Model, Cell: UITableViewCell, Action>: FastListConnector<Model, Cell, Action>, UITableViewDelegate, UITableViewDataSource{

    public init(_ table: UITableView, cellUpdateBlock: @escaping CellUpdateBlock) {
        super.init(implementation: table, cellUpdateBlock: cellUpdateBlock)
    }
    
    public init(_ table: UITableView, cellUpdateBlock: @escaping CellUpdateBlock, shouldIgnoreDuplicates: Bool) where Model: Equatable {
        super.init(implementation: table, cellUpdateBlock: cellUpdateBlock, shouldIgnoreDuplicates: shouldIgnoreDuplicates)
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return extractCell(list: tableView, indexPath: indexPath.tablePath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        processCellPressed(indexPath: indexPath.tablePath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

public class FastSectionTableConnector<Model, SubModel, Cell: UITableViewCell, SubCell: UITableViewCell, Action>: FastListSectionConnector<Model, SubModel, Cell, SubCell, Action>, UITableViewDelegate, UITableViewDataSource{

    public init(_ table: UITableView, shouldAddSectionTapListener: Bool = true, subitemsExtractor: @escaping SubItemsExtractor, subcellUpdateBlock: @escaping SubCellUpdateBlock, cellUpdateBlock: @escaping CellUpdateBlock) {
        super.init(implementation: table, shouldAddSectionTapListener: shouldAddSectionTapListener, subitemsExtractor: subitemsExtractor, subcellUpdateBlock: subcellUpdateBlock, cellUpdateBlock: cellUpdateBlock)
    }
    
//    public init(_ table: UITableView, subitemsExtractor: @escaping SubItemsExtractor, subcellUpdateBlock: @escaping SubCellUpdateBlock, cellUpdateBlock: @escaping CellUpdateBlock, shouldIgnoreDuplicates: Bool) where Model: Equatable {
//        super.init(implementation: table, cellUpdateBlock: cellUpdateBlock, shouldIgnoreDuplicates: shouldIgnoreDuplicates)
//    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subitems(in: section).count
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return extractCell(list: tableView, indexPath: FastIndexPath(item: section))
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return extractSubcell(list: tableView, indexPath: indexPath.tablePath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        processSubcellPressed(indexPath: indexPath.tablePath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
