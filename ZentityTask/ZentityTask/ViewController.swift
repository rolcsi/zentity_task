//
//  ViewController.swift
//  ZentityTask
//
//  Created by Roland Beke on 20.6.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let key = "ShelfTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: key, for: indexPath) as? ShelfTableViewCell else {
            fatalError("Cell \(ShelfTableViewCell.self) was not dequed")
        }
        
        let book = Book(
            id: "",
            title: "",
            thumbnail: "http://geo-assets.tedcdn.com/pico_iyer/TEDBook_Iyer_250x215.jpg",
            new: true,
            thumbExt: "")
        
        cell.addBooks(books: [book, book])


    
        return cell
    }

}

