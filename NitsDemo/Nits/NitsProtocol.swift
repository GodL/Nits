//
//  NitsProtocol.swift
//  NitsDemo
//
//  Created by imac on 2018/5/21.
//  Copyright © 2018年 com.GodL.github. All rights reserved.
//

import Foundation

public protocol NitsItemProtocol: Equatable{
    associatedtype KeyType
    associatedtype ValueType
    var key: KeyType {set get}
    var value: ValueType {set get}
    var cost: UInt {set get}
}

public protocol NitsLRUProtocol {
    var totalCost: UInt {set get}
    var totalCount: UInt {set get}
}

public protocol LinkNodeProtocol {
    associatedtype itemType
    associatedtype valueType
    var prev: itemType? {set get}
    var next: itemType? {set get}
    var value: valueType {set get}
}
