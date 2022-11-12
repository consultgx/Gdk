//
//  File.swift
//  
//
//  Created by G on 2022-11-11.
//

import Foundation

public class LinkedListNode {
    public let previous: LinkedListNode?
    public var next: LinkedListNode?
    public let value: Int
    public init(previous: LinkedListNode? = nil, next: LinkedListNode? = nil, value: Int) {
        self.previous = previous
        self.next = next
        self.value = value
    }
    
    public func reverseList(head: LinkedListNode?) -> LinkedListNode? {
        var prev: LinkedListNode? = nil ; var curr = head
        while curr != nil {
            let temp = curr?.next
            curr?.next = prev
            prev = curr
            curr = temp
        }
        return prev
    }
    
}


public class TrieBubble<T: Hashable & Comparable> {
    public var inherentValue: T?
    public weak var parent: TrieBubble?
    public var children: [T: TrieBubble] = [:]
    // terminating specially needed when buidling dictionary
    public var isTerminating = false
    
    public init(value: T? = nil, parent: TrieBubble? = nil) {
        self.inherentValue = value
        self.parent = parent
    }
    
    public func add(value: T) {
        guard children[value] == nil else {
            return
        }
        children[value] = TrieBubble(value: value, parent: self)
    }
}



public class BinarySearchTree<T: Comparable & Hashable> {
    private(set) public var value: T
    private(set) public var parent: BinarySearchTree?
    private(set) public var left: BinarySearchTree?
    private(set) public var right: BinarySearchTree?
    
    public init(value: T) {
        self.value = value
    }
    
    
    // recursive dfs
    public func dfs(root: BinarySearchTree?) {
        guard let r = root else {return}
        print(r.value)
        dfs(root: r.left)
        dfs(root: r.right)
    }
    
    // iterative bfs
    public func bfs(root: BinarySearchTree<Int>?) {
        guard let r = root else {return}
        var queue = [BinarySearchTree<Int>]()
        queue.append(r)
        while !queue.isEmpty {
            for item in queue {
                print(item.value)
            }
            if let l = queue[0].left {
                queue.append(l)
            }
            if let r = queue[0].right {
                queue.append(r)
            }
            queue.removeFirst()
        }
    }
    
}

public class TreeNode<T: Comparable & Hashable> {
    public var left: TreeNode?
    public var right: TreeNode?
    public var parent: TreeNode?
    public var value: T
    
    public init(left: TreeNode? = nil, right: TreeNode? = nil, parent: TreeNode? = nil, value: T) {
        self.left = left
        self.right = right
        self.parent = parent
        self.value = value
    }
}

public class GraphNode {
    public var edges: [GraphEdge]?
    public var val: Int?
}

public class GraphEdge {
    public var neighbor: GraphNode?
}

public func quickSort<T: Comparable>(_ a: [T]) -> [T] {
    guard a.count > 1 else { return a }
    let pivot = a[a.count/2]
    let less = a.filter { $0 < pivot }
    let equal = a.filter { $0 == pivot }
    let greater = a.filter { $0 > pivot }
    return quickSort(less) + equal + quickSort(greater)
}

public func mergeSort<T: Comparable>(_ array: [T]) -> [T] {
    guard array.count > 1 else { return array }
    let middleIndex = array.count / 2
    let leftArray = mergeSort(Array(array[0..<middleIndex]))
    let rightArray = mergeSort(Array(array[middleIndex..<array.count]))
    return merge(leftSide: leftArray, rightSide: rightArray)
}

public func merge<T: Comparable>(leftSide: [T], rightSide: [T]) -> [T] {
    var leftIndex = 0
    var rightIndex = 0
    var finalContainer: [T] = []
    if finalContainer.capacity < leftSide.count + rightSide.count {
        finalContainer.reserveCapacity(leftSide.count + rightSide.count)
    }
    
    while true {
        guard leftIndex < leftSide.endIndex else {
            finalContainer.append(contentsOf: rightSide[rightIndex..<rightSide.endIndex])
            break
        }
        guard rightIndex < rightSide.endIndex else {
            finalContainer.append(contentsOf: leftSide[leftIndex..<leftSide.endIndex])
            break
        }
        
        if leftSide[leftIndex] < rightSide[rightIndex] {
            finalContainer.append(leftSide[leftIndex])
            leftIndex += 1
        } else {
            finalContainer.append(rightSide[rightIndex])
            rightIndex += 1
        }
    }
    return finalContainer
}
