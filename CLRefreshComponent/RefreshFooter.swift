//
//  RefreshFooter.swift
//  CailiComponentsDemo
//
//  Created by kal on 2018/5/15.
//  Copyright © 2018年 kal. All rights reserved.
//

import UIKit

class RefreshFooter: BaseRefreshComponnent {

    var label: UILabel = UILabel.init()
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if let tableView = newSuperview as? UITableView {
            self.frame = CGRect.init(x: 0, y: self.tableView?.contentSize.height ?? 0, width: tableView.contentSize.width, height: self.containerHeight)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.containerHeight = 120.0
        self.backgroundColor = UIColor.yellow
        self.addSubview(self.label)
        self.label.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func startRefreshing() {
        if self.refreshState == .normal {
            self.refreshState = .refreshing
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.tableView?.contentInset.bottom = self.containerHeight
                    self.tableView?.setContentOffset(CGPoint.init(x: self.tableView?.contentOffset.x ?? 0, y: self.toBottomOffset() + self.containerHeight), animated: false)
                }
            }
            
            self.refreshingAnimate()
        }
    }
    
    override func endRefreshing() {
        if self.refreshState == .refreshing {
            self.refreshState = .normal
            UIView.animate(withDuration: 0.5) {
                self.tableView?.contentInset.bottom = 0
            }
            self.finishedAnimate()
        }
    }
    
    override func prepareAnimate(_ offsetY: CGFloat) {
        if offsetY > toBottomOffset() + containerHeight {
            self.label.text = "松开加载"
        } else {
            self.label.text = "上拉加载"
        }
    }
    
    override func refreshingAnimate() {
        self.label.text = "加载中..."
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
            self.endRefreshing()
        })
    }
    
    override func finishedAnimate() {
        self.label.text = "加载完毕"
    }
    
    override func contentSizeChanged(_ size: CGSize) {
        if let tableView = self.tableView {
            let height = size.height < tableView.frame.height ? tableView.frame.height : size.height
            self.frame.origin.y = height
        }
        
        self.frame.size.width = size.width
        self.label.frame = CGRect.init(x: 0, y: 0, width: size.width, height: self.frame.height)
        self.label.bounds.origin = CGPoint.zero
    }
    
    override func contentOffsetDidChange(_ newOffset: CGPoint, _ oldOffset: CGPoint)
    {
        guard let tableView = self.tableView else { return }
        let new = newOffset.y
        let old = oldOffset.y
        
        
        var isTouching = false
        
        let toTop: Bool = new < old // 上拉
        let toBottom: Bool = new >= old    // 下滑
        
        // 拉伸过refreshHeader
        
        let downHeader: Bool = new >= toBottomOffset() + containerHeight
        let inHeader: Bool = new < toBottomOffset() + containerHeight && new > toBottomOffset()
        
        if let numberOfTouches = self.tableView?.panGestureRecognizer.numberOfTouches {
            isTouching = numberOfTouches > 0
        }
        
        if self.refreshState == .refreshing {
            if toTop, new < toBottomOffset(), isTouching {
                self.refreshState = .normal
                tableView.contentInset.bottom = 0
            } else {
                if toTop, inHeader, isTouching {
//                    tableView.contentInset.bottom = new - tableView.contentSize.height
                }
                return
            }
        }
        
        if toBottom, downHeader {
            if isTouching {
                self.prepareAnimate(new)
            }
        }
        
        if toTop, downHeader {
            if isTouching {
                self.prepareAnimate(new)
            } else {
                self.startRefreshing()
            }
        }
        
        if toBottom, inHeader {
            if isTouching {
                self.prepareAnimate(new)
            }
        }
        
        if toTop, inHeader {
            // 回弹和上拉
            self.prepareAnimate(new)
        }
    }
    
    // 拉到最底部时的offset
    private func toBottomOffset() -> CGFloat {
        guard let tableView = tableView else{
            return 0
        }
        if tableView.contentSize.height - tableView.frame.height > 0 {
            return tableView.contentSize.height - tableView.frame.height
        }
        return 0
    }
}
