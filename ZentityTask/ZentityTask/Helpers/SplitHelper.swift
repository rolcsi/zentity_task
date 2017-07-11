//
//  SplitHelper.swift
//  ZentityTask
//
//  Created by Roland Beke on 6.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit

class SplitHelper: NSObject {

    static func splitBooks(from array: [Book]) -> [[Book]] {
        
        let splitCount = UIDevice.current.orientation.isPortrait ? 2 : 3
        
        var splitedArray: [[Book]] = []
        var tmpArray: [Book] = []
        
        for book in array {
            if tmpArray.count < splitCount {
                tmpArray.append(book)
            } else {
                splitedArray.append(tmpArray)
                tmpArray.removeAll()
                tmpArray.append(book)
            }
        }
        
        if tmpArray.count > 0 {
            splitedArray.append(tmpArray)
            tmpArray.removeAll()
        }
        
        return splitedArray
    }
}
