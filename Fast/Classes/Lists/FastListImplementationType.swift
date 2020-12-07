//
//  FastListImplementation.swift
//  FastArchitecture
//
//  Created by Nikita Arkhipov on 04.12.2020.
//

import Foundation
import ReactiveKit
import Bond

fileprivate struct FastUICollectionViewKeys {
    static var Connector = "Connector"
}

public protocol FastListImplementationType: class {
    func escapingReloadBlock() -> (() -> Void)
    
    func connect(with connector: NSObjectProtocol?)
    
    func deque<Cell>(cellIdentifier: String, indexPath: FastIndexPath) -> Cell where Cell: NSObject
}

extension FastListImplementationType{
    public var connector: NSObjectProtocol?{
        get { return objc_getAssociatedObject(self, &FastUICollectionViewKeys.Connector) as? NSObject }
        set {
            objc_setAssociatedObject(self, &FastUICollectionViewKeys.Connector, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            connect(with: newValue)
        }
    }
}

extension UICollectionView: FastListImplementationType{
    public func escapingReloadBlock() -> (() -> Void) {
        return { [weak self] in self?.reloadData() }
    }
    
    public func connect(with connector: NSObjectProtocol?) {
        delegate = connector as? UICollectionViewDelegateFlowLayout
        dataSource = connector as? UICollectionViewDataSource
    }
    
    public func deque<Cell>(cellIdentifier: String, indexPath: FastIndexPath) -> Cell where Cell: NSObject {
        return dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath.collectionPath) as! Cell
    }
}

extension UITableView: FastListImplementationType{
    public func escapingReloadBlock() -> (() -> Void) {
        return { [weak self] in self?.reloadData() }
    }
    
    public func connect(with connector: NSObjectProtocol?) {
        delegate = connector as? UITableViewDelegate
        dataSource = connector as? UITableViewDataSource
    }
    
    public func deque<Cell>(cellIdentifier: String, indexPath: FastIndexPath) -> Cell where Cell: NSObject {
        return dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath.tablePath) as! Cell
    }
}
