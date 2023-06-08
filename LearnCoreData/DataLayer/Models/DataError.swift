//
//  DataError.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation

enum DataError: Error {
    case missingRequiredFields(String)
    
    case invalidParameters(operation: String, parameters: [Any])
    
    case badRequest
    
    case unauthorized
    
    case paymentRequired
    
    case forbidden
    
    case notFound
    
    case requestEntityTooLarge

    case unprocessableEntity
    
    case http(httpResponse: HTTPURLResponse, data: Data)
    
    case invalidResponse(Data)
    
    case deleteOperationFailed(String)
    
    case network(URLError)
    
    case unknown(Error?)
    
    case coreData(String)
}

func mapResponse(response: (data: Data, response: URLResponse)) throws -> Data {
    guard let httpResponse = response.response as? HTTPURLResponse else {
        return response.data
    }
    
    switch httpResponse.statusCode {
    case 200..<300:
        return response.data
    case 400:
        throw DataError.badRequest
    case 401:
        throw DataError.unauthorized
    case 402:
        throw DataError.paymentRequired
    case 403:
        throw DataError.forbidden
    case 404:
        throw DataError.notFound
    case 413:
        throw DataError.requestEntityTooLarge
    case 422:
        throw DataError.unprocessableEntity
    default:
        throw DataError.http(httpResponse: httpResponse, data: response.data)
    }
}
