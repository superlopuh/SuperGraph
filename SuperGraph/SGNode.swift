//
//  SGNode.swift
//  SpaTyper
//
//  Created by Alexandre Lopoukhine on 03/03/2015.
//
//

import Foundation


public class SGNode<N: Equatable,E: Hashable>: Equatable, Hashable, Printable {
    typealias ValueType = N
    typealias EdgeValueType = E
    
    public let nodeID: Int
    public var value: ValueType
    public var edgesIn: Set<SGEdge<N,EdgeValueType>>  = Set<SGEdge<N,EdgeValueType>>()
    public var edgesOut: Set<SGEdge<N,EdgeValueType>> = Set<SGEdge<N,EdgeValueType>>()
    
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
    
    public lazy var nodesOut: Set<SGNode<N,E>> = {
        var nodesOut = Set<SGNode<N,E>>()
        
        for edge in self.edgesOut {
            nodesOut.insert(edge.nodeEnd)
        }
        
        return nodesOut
    }()
    
    public lazy var nodesIn: Set<SGNode<N,E>> = {
        var nodesIn = Set<SGNode<N,E>>()
        
        for edge in self.edgesIn {
            nodesIn.insert(edge.nodeEnd)
        }
        
        return nodesIn
    }()
}

public func ==<N,E>(lhs: SGNode<N,E>, rhs: SGNode<N,E>) -> Bool {
    return lhs.nodeID == rhs.nodeID
}


