//
//  File.swift
//  
//
//  Created by G on 2022-11-11.
//

import Foundation

public class GOperations {
    
    public static func opsOnGCD() {
        // for multiple tasks at tandem
        let gp = DispatchGroup()
        gp.notify(queue: .global(qos: .userInitiated)) {
            // can execute a final task, taking care of all child tasks which ran in tandem.
        }
        
        // backgrounded thread work
        DispatchQueue.global(qos: .userInitiated).async {
            
        }
        
        // main thread..
        DispatchQueue.main.async {
            
        }
        
    }
    
    public static func blockOps() {
        
        let op1 = BlockOperation {
            Thread.sleep(forTimeInterval: 4)
        }

        let op2 = BlockOperation {
            Thread.sleep(forTimeInterval: 4)
        }
        
        op2.addDependency(op1)
        
        // Same Queue, but with dependency
        let queue = OperationQueue()
        queue.addOperation(op1)
        queue.addOperation(op2)
        queue.waitUntilAllOperationsAreFinished()
        
        // different queues
        let queue1 = OperationQueue()
        let queue2 = OperationQueue()
        queue1.addOperation(op1)
        queue2.addOperation(op2)
        queue2.waitUntilAllOperationsAreFinished()
    }
    
   
}
