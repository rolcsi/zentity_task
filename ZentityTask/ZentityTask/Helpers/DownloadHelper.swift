//
//  DownloadHelper.swift
//  ZentityTask
//
//  Created by Roland Beke on 6.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit

class DownloadHelper: NSObject, XMLParserDelegate {

    static let url = URL(string: "http://www.lukaspetrik.cz/filemanager/tmp/reader/data.xml")
 
    var parser = XMLParser()
    var arrStack = Array<AnyObject>()
    var elements = NSMutableDictionary()
    var textInProgress = ""
    
    // MARK: DownloadImage methods
    
    static func downloadImage(from urlString: String, completion: @escaping (UIImage) -> ()) {
        
        let optionalUrl = URL(string: urlString)
        
        guard let url = optionalUrl else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            DispatchQueue.main.async() { () -> Void in
                
                if let data = data, error == nil {
                    
                    guard let image = UIImage(data: data) else {
                    
                        debugPrint("Data to UIImage fail with url: \(urlString)")
                        completion(#imageLiteral(resourceName: "no_image"))
                        return
                    }
                    
                    completion(image)
                } else { completion(#imageLiteral(resourceName: "no_image")) }
            }
        }.resume()
    }
    
    
    // MARK: XML to Book binding methods
    
    public func arrayToObjects() -> [Book] {
        
        let xmlArray = self.parseXMLToArray()
        var array: [Book] = []
        
        guard let root = xmlArray.first as? NSDictionary,
            let zreader = root.object(forKey: "ZREADER") as? NSDictionary,
            let books = zreader.object(forKey: "BOOK") else { return array }
        
        if let books = books as? Array<AnyObject> {
            
            // Array of books in dictionary
            for book in books {
                
                guard let bookObj = self.bindBook(book: book) else { continue }
                array.append(bookObj)
            }
        } else {
            
            // Only one book in dictionary
            guard let bookObj = self.bindBook(book: books) else { return array }
            array.append(bookObj)
        }
        
        return array
    }
    
    private func parseXMLToArray() -> Array<AnyObject> {
        
        self.arrStack.append(self.elements)
        
        guard let url = DownloadHelper.url, let parser = XMLParser(contentsOf: url) else { return [] }
        self.parser = parser
        self.parser.delegate = self
        self.parser.parse()
        
        return arrStack
    }
    
    private func bindBook(book: Any?) -> Book? {
        
        guard let book = book as? NSDictionary else { return nil }
        
        guard let id = self.stringFromDict(dict: book, key: "ID"),
            let title = self.stringFromDict(dict: book, key: "TITLE"),
            let thumbnail = self.stringFromDict(dict: book, key: "THUMBNAIL"),
            let new = self.stringFromDict(dict: book, key: "NEW"),
            let thumbExt = self.stringFromDict(dict: book, key: "THUMB_EXT") else { return nil }
        
        return Book(
            id: id,
            title: title,
            thumbnail: thumbnail,
            new: new.toBool(),
            thumbExt: thumbExt)
    }
    
    private func stringFromDict(dict: NSDictionary, key: String) -> String? {
        
        guard let keyDict = dict.object(forKey: key) as? NSDictionary,
            let value = keyDict.object(forKey: "value") else { return nil }
        
        return value as? String
    }
    
    // MARK: - XMLParserDelegate methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        // Create dictionary for current Level
        let parentDict = arrStack.last
        
        // Create child dict and add attributes dict in to that
        let childDict = NSMutableDictionary()
        childDict.addEntries(from: attributeDict)
        
        // Check any item for same node exist
        // If there than we need to create array for same
        if let existingValue = parentDict?.object(forKey: elementName) {
            var array:[AnyObject] = []
            
            if existingValue is Array<AnyObject> {
                
                // Use already created array
                guard let existingValue = existingValue as? [AnyObject] else { return }
                
                array = existingValue
                array.append(childDict)
                parentDict?.setValue(array, forKey: elementName)
            } else {
                
                // Replace child dict to array
                array.append(existingValue as AnyObject)
                array.append(childDict)
                
                parentDict?.setValue(array, forKey: elementName)
                
            }
        } else {
            
            // No current value update dictionary
            parentDict?.setValue(childDict, forKey: elementName)
        }
        
        // Update stack
        arrStack.append(childDict)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        // Update parent dict with value
        let dictInProgress = arrStack.last
        
        if self.textInProgress.lengthOfBytes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) > 0 {
            
            dictInProgress?.setValue(textInProgress, forKey: "value")
            textInProgress = ""
        }
        
        // Remove current node
        arrStack.removeLast()
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        textInProgress = textInProgress + string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        debugPrint("Parser failure error: ", parseError)
    }
}
