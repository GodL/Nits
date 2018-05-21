//
//  Nits.swift
//  NitsDemo
//
//  Created by imac on 2018/5/21.
//  Copyright © 2018年 com.GodL.github. All rights reserved.
//

import Foundation

public class Nits<Key,Value> where Key : Hashable {
    public var name: String?
    public var releaseQueue: DispatchQueue
    
    fileprivate struct NitsItem: NitsItemProtocol {
        
        var key: Key
        
        var value: Value
        
        var cost: Int
        
        var time: TimeInterval
        
        static func == (left: NitsItem,right: NitsItem) -> Bool {
            return left.key == right.key
        }
    }
    
    init(_ name: String) {
        self.name = name
        self.releaseQueue = DispatchQueue.init(label: "com.release.nits", qos: .utility, attributes: DispatchQueue.Attributes.concurrent);
    }
}
