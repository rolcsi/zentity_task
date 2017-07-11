//
//  ViewController.swift
//  ZentityTask
//
//  Created by Roland Beke on 20.6.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SplitHelper {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var allBooks: [Book] = []
    fileprivate var splitedBooks: [[Book]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadAndSplitBooks()
    }
    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        splitBooks()
        self.tableView.reloadData()
    }
    
    // MARK: - Private methods
    
    fileprivate func loadAndSplitBooks() {
        
        let downloadHelper = DownloadHelper.init()
        self.allBooks = downloadHelper.arrayToObjects()
        self.splitBooks()
    }
    
    fileprivate func splitBooks() {
        
        let splitedBooks = splitBooks(from: self.allBooks)
        self.splitedBooks = splitedBooks
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.splitedBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let key = "ShelfTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: key, for: indexPath) as? ShelfTableViewCell else {
            fatalError("Cell \(ShelfTableViewCell.self) was not dequed")
        }
        
        cell.removeBookViews()
        
        if indexPath.row < self.splitedBooks.count {
            cell.addBooks(books: self.splitedBooks[indexPath.row])
        }
        
        return cell
    }
}

