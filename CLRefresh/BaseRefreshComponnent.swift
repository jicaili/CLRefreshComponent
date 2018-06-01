//
//  BaseRefreshComponnent.swift
//  CailiComponentsDemo
//
//  Created by kal on 2018/5/16.
//  Copyright © 2018年 kal. All rights reserved.
//

import UIKit

class BaseRefreshComponnent: UIView {

    var containerHeight: CGFloat = 90
    
    var refreshState: RefreshHeaderState = .normal
    
    private var refreshingBlcok: (() -> Void)?
    
    weak var tableView: UITableView? {
        didSet {
            if tableView != nil {
                self.addObserve()
            }
        }
    }
    
    
    static func instance(_ refreshingBlock: (() -> Void)?) -> BaseRefreshComponnent{
        let refreshComponent = BaseRefreshComponnent.init(frame: CGRect.zero)
        refreshComponent.refreshingBlcok = refreshingBlock
        return refreshComponent
    }
    
    // MARK: 给子类实现
    
    func startRefreshing() {
    }
    
    func endRefreshing() {
    }
    
    /// 准备刷新动画
    func prepareAnimate(_ offsetY: CGFloat) {
        
    }
    /// 刷新动画
    func refreshingAnimate() {
        
    }
    /// 完成动画
    func finishedAnimate() {
        
    }
    
    func contentSizeChanged(_ size: CGSize) {
        
    }
    
    func contentOffsetDidChange(_ newOffset: CGPoint, _ oldOffset: CGPoint)
    {
        
    }
    
    // MARK: 私有
    
    private func addObserve()
    {
        let options: NSKeyValueObservingOptions = [.new, .old]
        if let table = tableView {
            table.addObserver(self, forKeyPath: "contentOffset", options: options, context: nil)
            table.addObserver(self, forKeyPath: "contentSize", options: options, context: nil)
        }
    }
    
    // MARK: 监听scroll
    internal override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        guard let new = change?[NSKeyValueChangeKey.newKey],
            let old = change?[NSKeyValueChangeKey.oldKey]
            else { return }
        if keyPath == "contentOffset" {
            if let newOffset = new as? CGPoint, let oldOffset = old as? CGPoint {
                contentOffsetDidChange(newOffset, oldOffset)
            }
        }
        else if keyPath == "contentSize" {
            if let newContentSize = new as? CGSize, let _ = old as? CGSize {
                self.contentSizeChanged(newContentSize)
            }
        }
    }
}
