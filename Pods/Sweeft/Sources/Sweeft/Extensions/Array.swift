//
//  Arrays.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

public extension Array {
    
    /// Returns empty array
    static var empty: [Element] {
        return []
    }
    
    /// Array with Elements and indexes for better for loops.
    var withIndex: [(element: Element, index: Int)] {
        return count.range => { (self[$0], $0) }
    }
    
    /// Random index contained in the array
    var randomIndex: Int? {
        return count.range?.random
    }
    
    var lastIndex: Int {
        return count - 1
    }
    
    /**
     Reduce with first item as partial result
     
     - Parameter nextPartialResult: resulthandler
     
     - Returns: Result
     */
    func reduce(_ nextPartialResult: @escaping (Element, Element) -> Element) -> Element? {
        guard let first = first else {
            return nil
        }
        return array(withLast: count - 1) ==> first ** nextPartialResult
    }
    
    /**
     Will turn any Array into a Dictionary with a handler
     
     - Parameter byDividingWith: Mapping function that breaks every element into a key and a value with index
     
     - Returns: Resulting dictionary
     */
    func dictionary<K, V>(byDividingWith handler: @escaping (Element, Int) -> (K, V)) -> [K:V] {
        return withIndex.dictionary(byDividingWith: handler)
    }
    
    /**
     Will give you the first n Elements of an Array
     
     - Parameter withFirst number: Number of items you want
     
     - Returns: Array with the first n Elements
     */
    func array(withFirst number: Int) -> [Element] {
        return self | number.range
    }
    
    /**
     Will give you the last n Elements of an Array
     
     - Parameter withFirst number: Number of items you want
     
     - Returns: Array with the last n Elements
     */
    func array(withLast number: Int) -> [Element] {
        return <>(<>self).array(withFirst: number)
    }
    
    /**
     Will give you the array starting at a specific index
     
     - Parameter index: Index at which you want to start
     
     - Returns: Array with the last n Elements
     */
    func array(from index: Int) -> [Element] {
        return array(withLast: count - index)
    }
    
    /**
     Will separate the array into different chunks of the same size
     
     - Parameter size: Size of the chunks
     
     - Returns: Array of chunks
     */
    func chunks(of size: Int) -> [[Element]] {
        guard !isEmpty else { return .empty }
        return [array(withFirst: size)] + array(from: size).chunks(of: size)
    }
    
    /**
     Will shift the index of an item to another inced
     
     - Parameter source: index of the item you want to move
     - Parameter destination: index where you want it to be at
     */
    mutating func move(itemAt source: Int, to destination: Int) {
        let element = self[source]
        remove(at: source)
        insert(element, at: destination)
    }
    
    /**
     Will shift the index of an item to another inced
     
     - Parameter source: index of the item you want to move
     - Parameter destination: index where you want it to be at
     
     - Returns: Resulting array
     */
    func moving(from source: Int, to destination: Int) -> [Element] {
        var copy = self
        copy.move(itemAt: source, to: destination)
        return copy
    }
    
    /**
     Will shuffle the contents of an array
     
     - Returns: shuffled copy
     */
    func shuffled() -> [Element] {
        guard !isEmpty else { return self }
        var array = self
        let swaps = randomIndex.? + 10
        swaps => {
            let a = (self.randomIndex).?
            let b = (self.randomIndex).?
            if a != b {
                array.swapAt(a, b)
            }
        }
        return array
    }
    
    /**
     Will shuffle the contents of an array in-place
     
     */
    mutating func shuffle() {
        self = shuffled()
    }
    
}

public extension Array where Element: Hashable {
    
    /// Checks if it has duplicates
    var hasDuplicates: Bool {
        return noDuplicates.count != count
    }
    
    /// Array without the duplicates
    var noDuplicates: [Element] {
        return set.array
    }
    
}

extension Array: Defaultable {
    
    /// Default Value
    public static var defaultValue: [Element] {
        return .empty
    }
    
}

public extension ExpressibleByArrayLiteral {
    
    static var empty: Self {
        return Self()
    }
    
}
