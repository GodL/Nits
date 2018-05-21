//
//  NitsLRU.swift
//  NitsDemo
//
//  Created by imac on 2018/5/21.
//  Copyright © 2018年 com.GodL.github. All rights reserved.
//

import Foundation

public class LRUNode<item: NitsItemProtocol> : LinkNodeProtocol {
    
    public typealias itemType = LRUNode
    public typealias valueType = item
    public weak var prev: LRUNode<item>?

    public weak var next: LRUNode<item>?
    
    public var value: item
    
    init(_ value: item) {
        prev = nil
        next = nil
        self.value = value;
    }
    
    deinit {
        prev = nil;
        next = nil;
    }
    
}

public class NitsLRU<Key,Value> where Key : Hashable {
    public var
}
