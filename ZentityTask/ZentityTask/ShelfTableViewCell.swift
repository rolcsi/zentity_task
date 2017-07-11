//
//  ShelfTableViewCell.swift
//  ZentityTask
//
//  Created by Roland Beke on 20.6.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit

class ShelfTableViewCell: UITableViewCell {
    
    func addBooks(books: [Book]) {
        
        let count = books.count
        guard count > 0 else { return }
        
        let key = "BookNib"
        
        for book in books {
            
            guard let bookView = UINib(nibName: key, bundle: nil)
                .instantiate(withOwner: nil, options: nil).first as? BookView else {
                
                    fatalError("\(key) xib was not loaded")
            }
            
            DownloadHelper.downloadImage(from: book.thumbnail, completion: { (image) in
                
                bookView.bookImageView.image = image
                bookView.activityIndicator.isHidden = true
                bookView.newImageView.isHidden = !book.new
            })
            
            bookView.titleLabel.text = book.title
            
            let width = self.frame.size.width / CGFloat(count)
            bookView.frame.size.width = width
            
            guard let indexOfBook = books.index(where: { (arrayBook) -> Bool in
                
                return arrayBook == book
            }) else { return }
            
            let bookPosition = CGFloat(books.distance(from: books.startIndex, to: indexOfBook))
            bookView.frame.origin.x = bookPosition * width
            
            self.addSubview(bookView)
        }
    }
    
    func removeBookViews() {
        
        for subview in self.subviews {
            if let view = subview as? BookView {
                view.removeFromSuperview()
            }
        }
    }

}
