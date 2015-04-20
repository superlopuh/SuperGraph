//
//  SGGraph.swift
//  SpaTyper
//
//  Created by Alexandre Lopoukhine on 03/03/2015.
//
//

import Foundation


public class SGGraph<N, E: Hashable>: Printable {
    public typealias NodeValueType = N
    public typealias EdgeValueType = E
    
    public var nodeIDCounter   = 1
    
    public var nodes: Set<SGNode<NodeValueType, EdgeValueType>> = Set<SGNode<NodeValueType, EdgeValueType>>()
    
    public init() {
        
    }
    
    public func addNode(nodeValue: NodeValueType) -> SGNode<NodeValueType, EdgeValueType> {
        let newNode = SGNode<NodeValueType, EdgeValueType>(nodeID: nodeIDCounter, value: nodeValue)
        nodeIDCounter++
        assert(!nodes.contains(newNode), "Error while inserting node")
        nodes.insert(newNode)
        return newNode
    }
    
    public func addEdge(edgeValue: EdgeValueType, fromNode: SGNode<NodeValueType, EdgeValueType>, toNode: SGNode<NodeValueType, EdgeValueType>) -> Bool {
        let newEdge: SGEdge<NodeValueType, EdgeValueType> = SGEdge(edgeValue: edgeValue, nodeStart: fromNode, nodeEnd: toNode)
        
        if nodes.contains(fromNode) && nodes.contains(toNode) {
            fromNode.edgesOut.insert(newEdge)
            toNode.edgesIn.insert(newEdge)
            return true
        } else {
            return false
        }
    }
    
    public var description: String {
        var description = "Graph description:\n"
        
        description += "Nodes:\n"
        for node in nodes {
            description += "Node \(node.nodeID):\t \n\(node.value)\n\n"
        }
        description += "\n"
        
        description += "Adjacency:\n"
        for node in nodes {
            description += NSString(format: "Node %3d", node.nodeID) as String
            description += ": \t"
            for edge in node.edgesOut {
                description += "\(edge.nodeEnd.nodeID) "
            }
            description += "\n"
        }
        
        return description
    }
    
    var edges: Set<SGEdge<N,E>> {
        var edges = Set<SGEdge<N,E>>()
        
        for node in nodes {
            edges.unionInPlace(node.edgesIn)
            edges.unionInPlace(node.edgesOut)
        }
        
        return edges
    }
    
    public func getNodeWithID(nodeID: Int) -> SGNode<N,E>? {
        let nodesWithGivenID = filter(nodes) {(node: SGNode<N,E>) -> Bool in
            return node.nodeID == nodeID
        }
        
        assert(nodesWithGivenID.count < 2, "More than one node with given ID, something went wrong")
        
        return nodesWithGivenID.first
    }
    
    func edgesForNodes(nodes: Set<SGNode<N,E>>) -> Set<SGEdge<N,E>> {
        var edges = Set<SGEdge<N,E>>()
        
        for node in nodes {
            for edge in node.edgesOut {
                if nodes.contains(edge.nodeEnd) {
                    edges.insert(edge)
                }
            }
        }
        
        return edges
    }
    
    public var reverseEdgeDictionary: [SGNode<N,E>:[SGNode<N,E>:SGEdge<N,E>]] {
        var dictionary: [SGNode<N,E>:[SGNode<N,E>:SGEdge<N,E>]] = [:]
        
        for edge in edges {
            if var dict = dictionary[edge.nodeStart] {
                dict[edge.nodeEnd] = edge
                dictionary[edge.nodeStart] = dict
            } else {
                dictionary[edge.nodeStart] = [edge.nodeStart:edge]
            }
        }
        
        return dictionary
    }
}

