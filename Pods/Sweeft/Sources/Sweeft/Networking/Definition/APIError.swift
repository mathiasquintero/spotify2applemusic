//
//  APIError.swift
//  Pods
//
//  Created by Mathias Quintero on 12/26/16.
//
//

import Foundation

/// Errors that might happen in an API Call
public enum APIError: Error {
    case noData /// There's no underlying data
    case timeout /// Connection has timed out
    case cannotPerformRequest /// There's not enough information to perform the request
    case invalidResponse // Response isn't valid
    case invalidStatus(code: Int, data: Data?) /// The http status code represents an unsuccesfull transaction
    case invalidData(data: Data) /// The Data does not represent the expected information
    case mappingError(json: JSON) /// Failed mapping the JSON Object to the respective Deserializable object
    case decodingError(error: DecodingError)
    case unknown(error: Error) /// Another error ocurred
}

extension APIError: GenerizableError {
    
    public init(error: Error) {
        self = .unknown(error: error)
    }
    
}
