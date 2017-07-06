//
//  ShelfTableViewCell.swift
//  ZentityTask
//
//  Created by Roland Beke on 20.6.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit

class ShelfTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func addBooks(books: [Book]) {
        
        guard books.count > 0 else { return }
        
        let key = "BookNib"
        let count = UIDevice.current.orientation.isPortrait ? 2 : 3
        
        var bookCount = CGFloat(0)
        
        for book in books {
            
            guard let bookView = UINib(nibName: key, bundle: nil)
                .instantiate(withOwner: nil, options: nil).first as? BookView else {
                
                    fatalError("\(key) xib was not loaded")
            }
            
            let optionalUrl = URL(string: book.thumbnail)
            guard let url = optionalUrl else { return }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async() { () -> Void in
               
                    bookView.bookImageView.image = UIImage(data: data)
                    bookView.activityIndicator.isHidden = true
                }
            }.resume()
            
            let width = self.frame.size.width / CGFloat(count)
            bookView.frame.size.width = width
            bookView.frame.origin.x = bookCount * width
            bookCount += 1
            
//            let indexOfBook = books.index(where: { (arrayBook) -> Bool in
//                return arrayBook == book
//            })
//            
//            
//            
//            bookView.frame.origin.x = books.distance(from: books.startIndex, to: indexOfBook)
            
            print("bookView frame: \(bookView.frame)")
            self.addSubview(bookView)
        }
        
    }

}
