//
//  Node.swift
//  SpaTyper
//
//  Created by Alexandre Lopoukhine on 03/03/2015.
//
//

import Foundation


public class Node<N: Equatable,E: Hashable>: Equatable, Hashable, Printable {
    typealias ValueType = N
    typealias EdgeValueType = E
    
    public let nodeID: Int
    public var value: ValueType
    public var edgesIn: Set<Edge<N,EdgeValueType>>  = Set<Edge<N,EdgeValueType>>()
    public var edgesOut: Set<Edge<N,EdgeValueType>> = Set<Edge<N,EdgeValueType>>()
    
    public var hashValue: Int {
        return nodeID
    }
    
    init(nodeID: Int, value: ValueType) {
        self.nodeID = nodeID
        self.value  = value
    }
    
    public var description: String {
        var description = "Node: id \(nodeID)\n"
        description += "Edges out: "
        for edge in edgesOut {
            description += " \(edge.nodeEnd.nodeID)"
        }
        description += "\nEdges in: "
        for edge in edgesIn {
            description += " \(edge.nodeStart.nodeID)"
        }
        return description
    }
    
    public lazy var nodesOut: Set<Node<N,E>> = {
        var nodesOut = Set<Node<N,E>>()
        
        for edge in self.edgesOut {
            nodesOut.insert(edge.nodeEnd)
        }
        
        return nodesOut
    }()
    
    public lazy var nodesIn: Set<Node<N,E>> = {
        var nodesIn = Set<Node<N,E>>()
        
        for edge in self.edgesIn {
            nodesIn.insert(edge.nodeEnd)
        }
        
        return nodesIn
    }()
}

public func ==<N,E>(lhs: Node<N,E>, rhs: Node<N,E>) -> Bool {
    return lhs.nodeID == rhs.nodeID
}


