//
//  File.swift
//  
//
//  Created by G on 2022-12-07.
//

import Foundation
import UIKit

@propertyWrapper public struct ImageManagerProperty<T> where T: UIImage {
    
    public let key: String
    public let urlString: String
    public let defaultValue: T

    public var wrappedValue: T {
        get {
            if let d = try? Data(contentsOf: URL(string: urlString)!) {
                return UIImage(data: d) as! T
            } else {
                return defaultValue
            }
            // todo: apply new ways of downloading uiimage, like async/ await version
        } set {
            // if caller needs to oveeride then
            // do something for newValue
            
            
        }
    }
}

public extension ImageManagerProperty {
    mutating func reset() {
        wrappedValue = defaultValue
    }
}

public func tester() {
    @ImageManagerProperty(key: "dynamicImage",urlString: "https://google.com/image1", defaultValue: UIImage(systemName: "circle")!) var dynamicImage: UIImage
//    $dynamicImage.reset()
}


