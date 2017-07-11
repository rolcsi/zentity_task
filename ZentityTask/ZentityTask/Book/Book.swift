//
//  Book.swift
//  ZentityTask
//
//  Created by Roland Beke on 6.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit

protocol BaseBook {
    var id: String { get }
    var title: String { get }
    var thumbnail: String { get }
    var new: Bool { get }
    var thumbExt: String { get }
    
}

extension Book: Equatable {
    static func ==(lhs: Book, rhs: Book) -> Bool {
        let booksEqual = lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.thumbnail == rhs.thumbnail &&
            lhs.new == rhs.new &&
            lhs.thumbExt == rhs.thumbExt
        return booksEqual
    }
}

struct Book: BaseBook {

    var id: String
    var title: String
    var thumbnail: String
    var new: Bool
    var thumbExt: String
}
