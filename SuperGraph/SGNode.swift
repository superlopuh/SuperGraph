//
//  SGNode.swift
//  SpaTyper
//
//  Created by Alexandre Lopoukhine on 03/03/2015.
//
//

import Foundation


public class SGNode<N,E: Hashable>: Equatable, Hashable, Printable {
    typealias ValueType = N
    typealias EdgeValueType = E
    
    public let nodeID: Int
    public var value: ValueType
    public var label: String
    public var edgesIn: Set<SGEdge<N,EdgeValueType>>  = Set<SGEdge<N,EdgeValueType>>()
    public var edgesOut: Set<SGEdge<N,EdgeValueType>> = Set<SGEdge<N,EdgeValueType>>()
    
    public var hashValue: Int {
        return nodeID
    }
    
    init(nodeID: Int, value: ValueType, label: String = "") {
        self.nodeID = nodeID
        self.value  = value
        self.label  = nodeID.description
    }
    
    public var description: String {
        var description = "Node: id \(nodeID), label \(label)\n"
        description += "Edges out: "
        for edge in edgesOut {
            description += " \(edge.nodeEnd.label)"
        }
        description += "\nEdges in: "
        for edge in edgesIn {
            description += " \(edge.nodeStart.label)"
        }
        return description
    }
    
    public var nodesOut: Set<SGNode<N,E>> {
        var nodesOut = Set<SGNode<N,E>>()
        
        for edge in self.edgesOut {
            nodesOut.insert(edge.nodeEnd)
        }
        
        return nodesOut
    }
    
    public var nodesIn: Set<SGNode<N,E>> {
        var nodesIn = Set<SGNode<N,E>>()
        
        for edge in self.edgesIn {
            nodesIn.insert(edge.nodeEnd)
        }
        
        return nodesIn
    }
    
    public func getEdgeToNodeWithID(nodeID: Int) -> SGEdge<N,E>? {
        let nodesWithGivenID = filter(edgesOut) {(edge: SGEdge<N,E>) -> Bool in
            return edge.nodeEnd.nodeID == nodeID
        }
        
        assert(nodesWithGivenID.count < 2, "More than one node with given ID, something went wrong")
        
        return nodesWithGivenID.first
    }
    
    public func getEdgeFromNodeWithID(nodeID: Int) -> SGEdge<N,E>? {
        let nodesWithGivenID = filter(edgesIn) {(edge: SGEdge<N,E>) -> Bool in
            return edge.nodeStart.nodeID == nodeID
        }
        
        assert(nodesWithGivenID.count < 2, "More than one node with given ID, something went wrong")
        
        return nodesWithGivenID.first
    }
}

public func ==<N,E>(lhs: SGNode<N,E>, rhs: SGNode<N,E>) -> Bool {
    return lhs.nodeID == rhs.nodeID
}


