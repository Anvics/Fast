//
//  FastCollectionConnector.swift
//  FastArchitecture
//
//  Created by Nikita Arkhipov on 04.12.2020.
//

import UIKit

public class FastCollectionConnector<Model, Cell: UICollectionViewCell, Action>: FastListConnector<Model, Cell, Action>, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{

    public init(_ collection: UICollectionView, cellUpdateBlock: @escaping CellUpdateBlock) {
        super.init(implementation: collection, cellUpdateBlock: cellUpdateBlock)
    }
    
    public init(_ collection: UICollectionView, cellUpdateBlock: @escaping CellUpdateBlock, shouldIgnoreDuplicates: Bool) where Model: Equatable {
        super.init(implementation: collection, cellUpdateBlock: cellUpdateBlock, shouldIgnoreDuplicates: shouldIgnoreDuplicates)
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return extractCell(list: collectionView, indexPath: indexPath.collectionPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        processCellPressed(indexPath: indexPath.collectionPath)
    }
}

public class FastSizedCollectionConnector<Model, Cell: UICollectionViewCell, Action>: FastCollectionConnector<Model, Cell, Action>{
    let size: CGSize
    
    public init(_ collection: UICollectionView, cellUpdateBlock: @escaping CellUpdateBlock, size: CGSize) {
        self.size = size
        super.init(collection, cellUpdateBlock: cellUpdateBlock)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return size
    }
}
