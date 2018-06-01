//
//  UITableView+Refresh.swift
//  CailiComponentsDemo
//
//  Created by kal on 2018/5/15.
//  Copyright © 2018年 kal. All rights reserved.
//

import Foundation

private struct AssociatedKeys {

    static var refreshHeader = "refreshHeader"
    static var refreshFooter = "refreshFooter"
}

import UIKit

extension UITableView {
    var refreshHeader: RefreshHeader? {
        set {
            if self.refreshHeader != nil {
                self.refreshHeader?.removeFromSuperview()
            }
            objc_setAssociatedObject(self, &AssociatedKeys.refreshHeader, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue?.tableView = self
            if let header = newValue {
                self.addSubview(header)
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.refreshHeader) as? RefreshHeader
        }
    }
    
    var refreshFooter: RefreshFooter? {
        set {
            if self.refreshFooter != nil {
                self.refreshFooter?.removeFromSuperview()
            }
            objc_setAssociatedObject(self, &AssociatedKeys.refreshFooter, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue?.tableView = self
            if let footer = newValue {
                self.addSubview(footer)
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.refreshFooter) as? RefreshFooter
        }
    }
}
