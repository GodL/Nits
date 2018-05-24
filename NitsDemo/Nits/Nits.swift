//
//  Nits.swift
//  NitsDemo
//
//  Created by imac on 2018/5/21.
//  Copyright © 2018年 com.GodL.github. All rights reserved.
//

import Foundation
import UIKit

public class Nits<Key,Value>: IteratorProtocol where Key : Hashable {
    
    public typealias Element = (Key,Value)
    
    fileprivate struct NitsItem: NitsItemProtocol {
        typealias KeyType = Key
        typealias ValueType = Value
        var key: KeyType
        
        var value: ValueType
        
        var cost: UInt
        
        init(key: KeyType,value: ValueType,cost: UInt) {
            self.key = key
            self.value = value
            self.cost = cost
        }
        
        static func == (left: NitsItem,right: NitsItem) -> Bool {
            return left.key == right.key
        }
    }
    
    public var name: String?
    
    public var releaseOnBackground: Bool = true {
        willSet {
            lru.releaseOnBackground = newValue
        }
    }
    
    public var totalCost: UInt {
        return lru.totalCost
    }
    
    public var totalCount: UInt {
        return lru.totalCount
    }
    
    public var cleanWhenMemoryWarning: Bool = true
    
    public var cleanWhenInBackground: Bool = true
    
    fileprivate var lru: NitsLRU<Key,NitsItem>
    private var costLimit: UInt = UInt.max
    private var countLimit: UInt = UInt.max
    private var lock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    convenience init(_ name: String?) {
        self.init(name, costLimit: .max, countLimit: .max)
    }
    
    convenience init() {
        self.init(nil)
    }
    
    init(_ name: String?,costLimit: UInt,countLimit: UInt) {
        self.name = name
        lru = NitsLRU()
        self.costLimit = costLimit
        self.countLimit = countLimit
        NotificationCenter.default.addObserver(self, selector: #selector(clean), name: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clean), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    func containsObject(key: Key) -> Bool {
        lock.wait()
        let flag = lru.contains(key: key)
        lock.signal()
        return flag
    }
    
    func setObject(key: Key?,value: Value?) {
        if key == nil {
            return
        }
        if value == nil {
            removeObject(key: key)
            return
        }
        _setObject(key: key!, value: value!, cost: 0)
    }
    
    func object(key: Key?) -> Value? {
        guard key != nil else {
            return nil
        }
        lock.wait()
        let obj = lru.object(key: key!)?.value
        lock.signal()
        return obj as? Value
    }
    
    func removeObject(key: Key?) {
        guard key != nil else {
            return
        }
        lock.wait()
        lru.removeObject(key: key!)
        lock.signal()
    }
    
    private func _setObject(key: Key,value: Value,cost: UInt) {
        let obj: NitsItem = NitsItem.init(key: key, value: value, cost: cost)
        lock.wait()
        lru.setObject(value: obj)
        if totalCount > countLimit || totalCost > costLimit {
            lru.removeLast()
        }
        lock.signal()
    }
    
    public func next() -> (Key, Value)? {
        let value:NitsItem? = lru.next()
        return (value?.key,value?.value) as? (Key, Value)
    }
    
    @objc func clean() {
        if cleanWhenInBackground || cleanWhenMemoryWarning {
            lock.wait()
            lru.clean()
            lock.signal()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
