//
//  NitsLRU.swift
//  NitsDemo
//
//  Created by imac on 2018/5/21.
//  Copyright © 2018年 com.GodL.github. All rights reserved.
//

import Foundation

public class LRUNode<item: NitsItemProtocol> : LinkNodeProtocol&Equatable {
    
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
    
    public static func == (lhs: LRUNode<item>, rhs: LRUNode<item>) -> Bool {
        return lhs.value == rhs.value
    }
    
}

public class NitsLRU<Key,Value>: NitsLRUProtocol&IteratorProtocol where Key : Hashable,Value: NitsItemProtocol {
    
    public typealias Element = Value
    
    public var totalCost: UInt = 0
    
    public var totalCount: UInt = 0
    
    public var releaseOnBackground: Bool = true
    
    fileprivate weak var lru_head: LRUNode<Value>? = nil
    fileprivate weak var lru_tail: LRUNode<Value>? = nil
    fileprivate var cache_hash: [Key:LRUNode<Value>] = [:]
    fileprivate let release_queue: DispatchQueue = DispatchQueue.init(label: "com.release.nits", qos: .utility, attributes: DispatchQueue.Attributes.concurrent);
    
    private var current: Int = 0;
    
    public func contains(key: Key) -> Bool {
        return cache_hash[key] != nil
    }
    
    public func setObject(value: Value) {
        let key: Key = value.key as! Key
        let node: LRUNode<Value>? = cache_hash[key]
        if node == nil {
            addHeader(value: value)
        }else {
            bringHeader(node: node!)
        }
        
    }
    
    public func removeObject(key: Key) {
        var node: LRUNode<Value>? = cache_hash[key]
        if let old = node {
            cache_hash.removeValue(forKey: key)
            if old.next != nil {
                old.next?.prev = old.prev
            }
            if old.prev != nil {
                old.prev?.next = old.next
            }
            if old == lru_head {
                lru_head = old.next
            }
            if old == lru_tail {
                lru_tail = old.prev
            }
            totalCount -= 1
            totalCost -= old.value.cost
            node = nil
        }
        
    }
    
    public func object(key: Key) -> LRUNode<Value>? {
        let node: LRUNode<Value>? = cache_hash[key]
        if let old = node {
            bringHeader(node: old)
        }
        return node
    }
    
    public func removeLast() {
        if let tail = lru_tail {
            cache_hash.removeValue(forKey: tail.value.key as! Key)
            tail.prev?.next = nil
            lru_tail = tail.prev
            totalCount -= 1
            totalCost -= tail.value.cost
        }
    }
    
    public func clean() {
        var old: [Key:LRUNode]? = cache_hash
        cache_hash = [:]
        lru_head = nil
        lru_tail = nil
        totalCount = 0
        totalCost = 0
        if releaseOnBackground {
            release_queue.async {
                if old != nil {
                    old = nil
                }
            }
        }
    }
    
    public func next() -> Value? {
        defer {
            current += 1
        }
        
        if totalCount == 0 || current >= totalCount {
            return nil
        }
        var index = current
        var node: LRUNode<Value>? = lru_head
        while (index - 1) >= 0 {
            node = node?.next
            index -= 1
        }
        return node?.value
    }
    
    private func addHeader(value: Value) {
        let new: LRUNode<Value> = LRUNode(value)
        if let header = self.lru_head {
            header.prev = new
            new.next = header
        }else {
            lru_tail = new
        }
        cache_hash[value.key as! Key] = new
        lru_head = new
        totalCost += value.cost
        totalCount += 1
    }
    
    private func bringHeader(node: LRUNode<Value>) {
        if lru_head == node {
            return
        }
        
        if node.next != nil {
            node.next!.prev = node.prev
        }
        if node == lru_tail {
            lru_tail = node.prev
        }
        lru_head?.prev = node
        node.prev = nil
        node.next = lru_head
        lru_head = node
    }
}
