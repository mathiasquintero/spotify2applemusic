//
//  APIObjectWithDetail.swift
//  Sweeft
//
//  Created by Mathias Quintero on 9/27/17.
//

import Foundation


@available(macOS 10.12, *)
public typealias APIBasic = Codable & Identifiable

@available(macOS 10.12, *)
public protocol APIObjectWithDetail: APIObjectValue {
    associatedtype Basic: APIBasic where Basic.Identifier == Identifier
    associatedtype Detail: Codable
    
    var basic: Basic { get }
    var detail: Detail? { get }
    
    init(basic: Basic, detail: Detail?)
}

@available(macOS 10.12, *)
extension APIObjectWithDetail {
    
    public var id: Identifier {
        return basic.id
    }
    
}

@available(macOS 10.12, *)
extension APIObjectWithDetail {
    
    public init(from decoder: Decoder) throws {
        
        let detail: Detail?
        do {
            detail = try .init(from: decoder)
        } catch DecodingError.keyNotFound {
            detail = nil
        }
        
        self.init(basic: try .init(from: decoder),
                  detail: detail)
    }
    
    public func encode(to encoder: Encoder) throws {
        try basic.encode(to: encoder)
        if let detail = detail {
            try detail.encode(to: encoder)
        }
    }
    
}
