//
//  Graph.swift
//  SpaTyper
//
//  Created by Alexandre Lopoukhine on 03/03/2015.
//
//

import Foundation


public class Graph<N: Equatable, E: Hashable>: Printable {
    typealias NodeValueType = N
    typealias EdgeValueType = E
    
    public var nodeIDCounter   = 1
    
    public var nodes: Set<Node<NodeValueType, EdgeValueType>> = Set<Node<NodeValueType, EdgeValueType>>()
    
    public init() {
        
    }
    
    public func addNode(nodeValue: NodeValueType) -> Node<NodeValueType, EdgeValueType> {
        let newNode = Node<NodeValueType, EdgeValueType>(nodeID: nodeIDCounter, value: nodeValue)
        nodeIDCounter++
        assert(!nodes.contains(newNode), "Error while inserting node")
        nodes.insert(newNode)
        return newNode
    }
    
    public func addEdge(edgeValue: EdgeValueType, fromNode: Node<NodeValueType, EdgeValueType>, toNode: Node<NodeValueType, EdgeValueType>) -> Bool {
        let newEdge: Edge<NodeValueType, EdgeValueType> = Edge(edgeValue: edgeValue, nodeStart: fromNode, nodeEnd: toNode)
        
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
    
    var edges: Set<Edge<N,E>> {
        var edges = Set<Edge<N,E>>()
        
        for node in nodes {
            edges.unionInPlace(node.edgesIn)
            edges.unionInPlace(node.edgesOut)
        }
        
        return edges
    }
    
    public var hamiltonianPaths: [[Edge<N,E>]] {
        
        // Assume path exists
        
        
        
        // Calculate forward closures, and sort by their size
        // The first node will include all other nodes
        
        func forwardClosure(node: Node<N,E>) -> Set<Node<N,E>> {
            var closure = Set<Node<N,E>>()
            closure.insert(node)
            
            var queue = Set<Node<N,E>>()
            
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
        
        let closurePairs: [(node: Node<N,E>, closure: Set<Node<N,E>>)] = Array<Node<N,E>>(nodes).map() {return ($0,forwardClosure($0))}
        let sortedPairs = closurePairs.sorted() { (pair1: (node: Node<N,E>, closure: Set<Node<N,E>>), pair2: (node: Node<N,E>, closure: Set<Node<N,E>>)) -> Bool in
            return pair1.closure.isSupersetOf(pair2.closure)
        }
        
        let closureSizePairs = sortedPairs.map() { (node: Node<N,E>, closure: Set<Node<N,E>>) -> (node: Node<N,E>, count: Int) in
            return (node, closure.count)
        }
        
        // Work backwards to isolate separate parts of graph
        var pathComponents: [[Node<N,E>]] = []
        
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
        var partialPaths: [Path<N,E>] = []
        
        // Insert paths in first component
        partialPaths = hamiltonianPathsForNodes(Set<Node<N,E>>(pathComponents[0]))
        
        for index in 1..<pathComponents.count {
            // Can do much faster with memoization
            // Even with a dumb array with stored values
            
            let pathComponentPaths = hamiltonianPathsForNodes(Set<Node<N,E>>(pathComponents[index]))
            
            var newPaths: [Path<N,E>] = []
            
            for pathSoFar in partialPaths {
                for componentPath in pathComponentPaths {
                    // find possible edges
                    for edge in pathSoFar.endNode.edgesOut {
                        if componentPath.startNode == edge.nodeEnd {
                            newPaths.append(Path<N,E>(path: pathSoFar.path + [edge] + componentPath.path, endNode: componentPath.endNode))
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
    
    func hamiltonianPathsForNodes(nodes: Set<Node<N,E>>) -> [Path<N,E>] {
        if nodes.count == 0 {
            return []
        } else if nodes.count == 1 {
            return [Path<N,E>(path: [], endNode: nodes.first!)]
        } else {
            var paths: [Path<N,E>] = []
            
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
    func hamiltonianPathsForNodes(nodes: Set<Node<N,E>>, fromNode beforeNode: Node<N,E>) -> [Path<N,E>] {
        if nodes.count == 0 {
            return []
        } else if nodes.count == 1 {
            var paths: [Path<N,E>] = []
            
            let endNode = nodes.first!
            
            for edge in beforeNode.edgesOut {
                if endNode == edge.nodeEnd {
                    paths.append(Path<N,E>(path: [edge], endNode: endNode))
                }
            }
            
            return paths
        } else {
            if nodes.count == 2 {
                
                
            }
            
            var paths: [Path<N,E>] = []
            
            for edge in beforeNode.edgesOut {
                if nodes.contains(edge.nodeEnd) {
                    let nextNode = edge.nodeEnd
                    var laterSet = nodes
                    laterSet.remove(nextNode)
                    
                    let laterPaths = hamiltonianPathsForNodes(laterSet, fromNode: nextNode)
                    
                    for laterPath in laterPaths {
                        paths.append(Path<N,E>(path: [edge] + laterPath.path, endNode: laterPath.endNode))
                    }
                }
            }
            
            // Maybe test for hamiltonian here
            
            return paths
        }
    }
    
    func edgesForNodes(nodes: Set<Node<N,E>>) -> Set<Edge<N,E>> {
        var edges = Set<Edge<N,E>>()
        
        for node in nodes {
            for edge in node.edgesOut {
                if nodes.contains(edge.nodeEnd) {
                    edges.insert(edge)
                }
            }
        }
        
        return edges
    }
    
    public var reverseEdgeDictionary: [Node<N,E>:[Node<N,E>:Edge<N,E>]] {
        var dictionary: [Node<N,E>:[Node<N,E>:Edge<N,E>]] = [:]
        
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

