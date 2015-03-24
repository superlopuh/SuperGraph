//
//  Path.swift
//  SuperGraph
//
//  Created by Alexandre Lopoukhine on 17/03/2015.
//  Copyright (c) 2015 bluetatami. All rights reserved.
//

import Foundation

struct Path<N: Equatable,E: Hashable> : Printable {
    let path:      [Edge<N,E>]
    let startNode:  Node<N,E>
    let endNode:    Node<N,E>
    
    init(path: [Edge<N,E>], endNode: Node<N,E>) {
        if let startNode = path.first?.nodeStart {
            // Path is not empty
            self.path       = path
            self.startNode  = startNode
            self.endNode    = endNode
        } else {
            // Path is empty, last node is first node
            self.path       = path
            self.startNode  = endNode
            self.endNode    = endNode
        }
    }
    
    var description: String {
        if path.count == 0 {
            return "<\(startNode.nodeID)>"
        } else {
            var description = "<\(path.first!.nodeStart.nodeID)"
            
            for index in 0..<path.count {
                description += " -> \(path[index].nodeEnd.nodeID)"
            }
            
            return description + ">"
        }
    }
}