//
//  SGDOTWriter.swift
//  SuperGraph
//
//  Created by Alexandre Lopoukhine on 17/04/2015.
//  Copyright (c) 2015 bluetatami. All rights reserved.
//

import Foundation

public class SGDOTWriter {
    public static func writeGraph<N, E: Hashable>(graph: SGGraph<N,E>, withName name: String, toFile outputFileAddress: NSURL) {
        // If folder doesn't exist, create one
        if let folderPath = outputFileAddress.URLByDeletingLastPathComponent?.path {
            // check if element is a directory
            var isDirectory: ObjCBool = ObjCBool(false)
            // Mutates isDirectory pointer
            NSFileManager.defaultManager().fileExistsAtPath(folderPath, isDirectory: &isDirectory)
            
            if !isDirectory {
                var error: NSError?
                
                NSFileManager.defaultManager().createDirectoryAtPath(folderPath, withIntermediateDirectories: false, attributes: nil, error: &error)
            }
        }
        
        // Create new .dot file
        if let dotFilePath = outputFileAddress.path {
            let dotData = dotDescriptionOfGraph(graph, withName: name).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            NSFileManager.defaultManager().createFileAtPath(dotFilePath, contents: dotData, attributes: nil)
        }
    }
    
    public static func dotDescriptionOfGraph<N, E: Hashable>(graph: SGGraph<N,E>, withName name: String) -> String {
        var dotDescription = "digraph \(name) {"
        
        for edge in graph.edges {
            dotDescription += "\n\t\(edge.nodeStart.label) -> \(edge.nodeEnd.label);"
        }
        
        return dotDescription + "\n}\n"
    }
}
