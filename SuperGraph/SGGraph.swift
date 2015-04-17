//
//  SGGraph.swift
//  SpaTyper
//
//  Created by Alexandre Lopoukhine on 03/03/2015.
//
//

import Foundation


public class SGGraph<N, E: Hashable>: Printable {
    typealias NodeValueType = N
    typealias EdgeValueType = E
    
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
    
    public var hamiltonianPaths: [[SGEdge<N,E>]] {
        
        // Assume path exists
        
        
        
        // Calculate forward closures, and sort by their size
        // The first node will include all other nodes
        
        func forwardClosure(node: SGNode<N,E>) -> Set<SGNode<N,E>> {
            var closure = Set<SGNode<N,E>>()
            closure.insert(node)
            
            var queue = Set<SGNode<N,E>>()
            
            for edge in node.edgesOut {
                queue.insert(edge.nodeEnd)
            }
            
            while (queue.count > 0) {
                let nextNode = queue.removeFirst()
                
                if !closure.contains(nextNode) {
                    for edge in nextNode.edgesOut {
                        queue.insert(edge.nodeEnd)
                    }
                    closure.insert(nextNode)
                }
            }
            
            return closure
        }
        
        let closurePairs: [(node: SGNode<N,E>, closure: Set<SGNode<N,E>>)] = Array<SGNode<N,E>>(nodes).map() {return ($0,forwardClosure($0))}
        let sortedPairs = closurePairs.sorted() { (pair1: (node: SGNode<N,E>, closure: Set<SGNode<N,E>>), pair2: (node: SGNode<N,E>, closure: Set<SGNode<N,E>>)) -> Bool in
            return pair1.closure.isSupersetOf(pair2.closure)
        }
        
        let closureSizePairs = sortedPairs.map() { (node: SGNode<N,E>, closure: Set<SGNode<N,E>>) -> (node: SGNode<N,E>, count: Int) in
            return (node, closure.count)
        }
        
        // Work backwards to isolate separate parts of graph
        var pathComponents: [[SGNode<N,E>]] = []
        
        if closureSizePairs.count == 0 {
            return []
        } else {
            var lastClosureSize = Int.max
            for pair in closureSizePairs {
                if pair.count < lastClosureSize {
                    pathComponents.append([pair.node])
                    lastClosureSize = pair.count
                } else if pair.count == lastClosureSize {
                    pathComponents[pathComponents.count - 1].append(pair.node)
                } else if pair.count > lastClosureSize {
                    println("Something went wrong, closures weren't sorted correctly")
                    return []
                }
            }
        }
        
//        println("Path components: \n\(pathComponents.map({return $0.map({return $0.nodeID})}))\n")
        
        // Build
        var partialPaths: [SGPath<N,E>] = []
        
        // Insert paths in first component
        partialPaths = hamiltonianPathsForNodes(Set<SGNode<N,E>>(pathComponents[0]))
        
        for index in 1..<pathComponents.count {
            // Can do much faster with memoization
            // Even with a dumb array with stored values
            
            let pathComponentPaths = hamiltonianPathsForNodes(Set<SGNode<N,E>>(pathComponents[index]))
            
            var newPaths: [SGPath<N,E>] = []
            
            for pathSoFar in partialPaths {
                for componentPath in pathComponentPaths {
                    // find possible edges
                    for edge in pathSoFar.endNode.edgesOut {
                        if componentPath.startNode == edge.nodeEnd {
                            newPaths.append(SGPath<N,E>(path: pathSoFar.path + [edge] + componentPath.path, endNode: componentPath.endNode))
                        }
                    }
                }
            }
            
            partialPaths = newPaths
            
            // Print paths so far
//            println("Paths so far:")
            for pathSoFar in partialPaths {
//                println(pathSoFar)
            }
            
        }
        
        return partialPaths.map({$0.path})
    }
    
    func hamiltonianPathsForNodes(nodes: Set<SGNode<N,E>>) -> [SGPath<N,E>] {
        if nodes.count == 0 {
            return []
        } else if nodes.count == 1 {
            return [SGPath<N,E>(path: [], endNode: nodes.first!)]
        } else {
            var paths: [SGPath<N,E>] = []
            
            for node in nodes {
                var otherNodes = nodes
                otherNodes.remove(node)
                
                let laterPaths = hamiltonianPathsForNodes(otherNodes, fromNode: node)
                
                paths += laterPaths
            }
            
            return paths
        }
    }
    
    // Returns path through all the Nodes in nodes, starting at beforeNode
    func hamiltonianPathsForNodes(nodes: Set<SGNode<N,E>>, fromNode beforeNode: SGNode<N,E>) -> [SGPath<N,E>] {
        if nodes.count == 0 {
            return []
        } else if nodes.count == 1 {
            var paths: [SGPath<N,E>] = []
            
            let endNode = nodes.first!
            
            for edge in beforeNode.edgesOut {
                if endNode == edge.nodeEnd {
                    paths.append(SGPath<N,E>(path: [edge], endNode: endNode))
                }
            }
            
            return paths
        } else {
            if nodes.count == 2 {
                
                
            }
            
            var paths: [SGPath<N,E>] = []
            
            for edge in beforeNode.edgesOut {
                if nodes.contains(edge.nodeEnd) {
                    let nextNode = edge.nodeEnd
                    var laterSet = nodes
                    laterSet.remove(nextNode)
                    
                    let laterPaths = hamiltonianPathsForNodes(laterSet, fromNode: nextNode)
                    
                    for laterPath in laterPaths {
                        paths.append(SGPath<N,E>(path: [edge] + laterPath.path, endNode: laterPath.endNode))
                    }
                }
            }
            
            // Maybe test for hamiltonian here
            
            return paths
        }
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
    
    public func dotDescriptionWithName(name: String) -> String {
        var dotDescription = "digraph \(name) {"
        
        for edge in edges {
            dotDescription += "\n\t\(edge.nodeStart.nodeID) -> \(edge.nodeEnd.nodeID);"
        }
        
        return dotDescription + "\n}\n"
    }
}

