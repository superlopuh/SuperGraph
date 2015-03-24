//
//  Edge.swift
//  SpaTyper
//
//  Created by Alexandre Lopoukhine on 03/03/2015.
//
//

import Foundation


public class Edge<N: Equatable,E: Hashable>: Equatable, Hashable, Printable {
    typealias ValueType     = E
    typealias NodeValueType = N
    
    public let edgeValue: ValueType
    public let nodeStart: Node<N,E>
    public let nodeEnd:   Node<N,E>
    
    public var hashValue: Int {
        let edgeHash = edgeValue.hashValue
        let nodeStartHash = nodeStart.hashValue
        let nodeEndHash     = nodeEnd.hashValue
        let hash = (edgeValue.hashValue << 8) ^ (nodeStart.hashValue << 16) ^ nodeEnd.hashValue
        return hash
    }
    
    public init(edgeValue: ValueType, nodeStart: Node<N,E>, nodeEnd: Node<N,E>) {
        self.edgeValue  = edgeValue
        self.nodeStart  = nodeStart
        self.nodeEnd    = nodeEnd
    }
    
    public var description: String {
        return "\(nodeStart.nodeID) -> \(nodeEnd.nodeID)"
    }
}

public func ==<N,E>(lhs: Edge<N,E>, rhs: Edge<N,E>) -> Bool {
    return lhs.edgeValue == rhs.edgeValue && lhs.nodeStart == rhs.nodeStart && lhs.nodeEnd == rhs.nodeEnd
}
