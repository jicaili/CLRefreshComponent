//
//  RefreshHeader.swift
//  CailiComponentsDemo
//
//  Created by kal on 2018/4/25.
//  Copyright © 2018年 kal. All rights reserved.
//

import UIKit

enum RefreshHeaderState {
    case normal
    case refreshing
    case finished
}

class RefreshHeader: BaseRefreshComponnent {
    
    var label: UILabel = UILabel.init()

    
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
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if let tableView = newSuperview as? UITableView {
            self.frame = CGRect.init(x: 0, y: -self.containerHeight, width: tableView.contentSize.width, height: self.containerHeight)
        }
    }
    
    override func startRefreshing() {
        if self.refreshState == .normal {
            self.refreshState = .refreshing
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.tableView?.contentInset.top = self.containerHeight
                    self.tableView?.setContentOffset(CGPoint.init(x: self.tableView?.contentOffset.x ?? 0, y: -self.containerHeight), animated: false)
                }
            }
            self.refreshingAnimate()
        }
    }
    
    override func endRefreshing() {
        if self.refreshState == .refreshing {
            self.refreshState = .normal
            self.finishedAnimate()
            UIView.animate(withDuration: 0.5) {
                self.tableView?.contentOffset.y = 0
                self.tableView?.contentInset.top = 0
            }
        }
    }
    
    override func prepareAnimate(_ offsetY: CGFloat) {
        if offsetY < -self.containerHeight {
            self.label.text = "释放刷新"
        } else {
            self.label.text = "下拉刷新"
        }
    }
    
    override func refreshingAnimate() {
        self.label.text = "刷新中..."
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
            self.endRefreshing()
        })
    }
    
    override func finishedAnimate() {
        self.label.text = "刷新完毕"
    }
    
    override func contentSizeChanged(_ size: CGSize) {
        self.frame.size.width = size.width
        self.label.bounds = self.frame
        self.label.frame.origin = CGPoint.zero
    }
    
    
    override func contentOffsetDidChange(_ newOffset: CGPoint, _ oldOffset: CGPoint) {
        guard tableView != nil else { return }
        let new = newOffset.y
        let old = oldOffset.y
        
        var isTouching = false
        
        let toTop: Bool = new < old // 上拉
        let toBottom: Bool = new >= old    // 下滑
        
        
        let upHeader: Bool = new < -containerHeight  // 在header上面
        let inHeader: Bool = new >= -containerHeight && new < 0     // 滑动到在header中间
        
        if let numberOfTouches = self.tableView?.panGestureRecognizer.numberOfTouches {
            isTouching = numberOfTouches > 0
        }
        
        if self.refreshState == .refreshing {
            // 取消刷新
            if toBottom, new >= 0, isTouching {
                self.refreshState = .normal
                self.tableView?.contentInset.top = 0
            } else {
                if inHeader, isTouching {
//                    self.tableView?.contentInset.top = -new
                }
                return
            }
        }
        
        if toTop, upHeader {
            if isTouching {
                // 正在上拉
                self.prepareAnimate(new)
            } else {
                // 代码控制滚动高度的不在考虑范围
            }
            
        }
        
        if toBottom, upHeader {
            if isTouching {
                // 正在下滑
                self.prepareAnimate(new)
            } else {
                // 开始刷新
                self.startRefreshing()
            }
        }
        
        if toTop, inHeader {
            if isTouching {
                // 正在上拉
                self.prepareAnimate(new)
            } else {
                // 代码控制滚动高度的不在考虑范围
            }
        }
        
        if toBottom, inHeader {
            // 回弹和下滑
            self.prepareAnimate(new)
        }
    }
}
