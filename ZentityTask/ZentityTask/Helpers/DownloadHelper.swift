//
//  DownloadHelper.swift
//  ZentityTask
//
//  Created by Roland Beke on 6.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit

class DownloadHelper: NSObject, XMLParserDelegate {

    let url = URL(string: "http://www.lukaspetrik.cz/filemanager/tmp/reader/data.xml")!
 
    var parser = XMLParser()
    var arrStack = Array<AnyObject>()
    var elements = NSMutableDictionary()
    var textInProgress = ""
    
    
    // MARK: DownloadImage
    
    static func downloadImage(from urlString: String, completion: @escaping (UIImage) -> ()) {
        
        let optionalUrl = URL(string: urlString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        
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
    
    public func parseXMLToArray() -> Array<AnyObject> {
        
        self.arrStack.append(self.elements)
        
        guard let parser = XMLParser(contentsOf: url) else { return [] }
        self.parser = parser
        self.parser.delegate = self
        self.parser.parse()
        
        return arrStack
    }
    
    public func arrayToObjects() -> [Book] {
        
        let xmlArray = self.parseXMLToArray()
        var array: [Book] = []
        
        guard let root = xmlArray.first as? NSDictionary,
            let zreader = root.object(forKey: "ZREADER") as? NSDictionary,
            let books = zreader.object(forKey: "BOOK") else { return array }
        
        if let books = books as? Array<AnyObject> {
            
            // array of books in dictionary
            for book in books {
                
                guard let bookObj = self.bindBook(book: book) else { continue }
                
                array.append(bookObj)
            }
        } else {
            
            // only one book in dictionary
            guard let bookObj = self.bindBook(book: books) else { return array }
            
            array.append(bookObj)
        }
        
        return array
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
        
        //Create dictionary for currnt Level
        let parentDict = arrStack.last
        
        //Create Child dict and Add attributes dict in to that
        
        let childDict = NSMutableDictionary()
        childDict.addEntries(from: attributeDict)
        
        //check any item for same Node Exist?
        //if there than we need to create array for same
//        let existingValue = parentDict![elementName]
        
        if let existingValue = parentDict?.object(forKey: elementName)
        {
            var array:[AnyObject] = []
            
            if existingValue is Array<AnyObject>
            {
                //use alreaddy created array
                array = existingValue as! [AnyObject]
                array.append(childDict)
                parentDict?.setValue(array, forKey: elementName)
            }
            else
            {
                //replace child dict to array of alreaddy created item so managing array
                //array.addObject(existingValue!)   // Harshit
                array.append(existingValue as AnyObject)
                array.append(childDict)
                //parentDict!.setValue(array, forKey: elementName)  // Harshit
                
                parentDict?.setValue(array, forKey: elementName)
                
            }
            
            //array.addObject(childDict) // Harshit
//            array.append(childDict)
//            print("parent: \(parentDict)")
        }
        else
        {
            //No current value update dictionary
            //parentDict.setValue(childDict, forKey: elementName) // Harshit
            parentDict?.setValue(childDict, forKey: elementName)
        }
        //update stack
        //        arrStack.addObject(childDict) // Harshit
        arrStack.append(childDict)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        //update parent dict with text info i.e /n
        let dictInProgress = arrStack.last
        // Set the text property can remove this but apple recommending this
        
        if self.textInProgress.lengthOfBytes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) > 0 {
            
            //            dictInProgress.setValue(textInProgress, forKey: "text")
            dictInProgress?.setValue(textInProgress, forKey: "value")
            //textInProgress = NSMutableString()    // Harshit
            textInProgress = ""
        }
        //Remove current node
        //arrStack.removeLastObject()   // Harshit
        arrStack.removeLast()
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        //        textInProgress.appendString(string)   // Harshit
        textInProgress = textInProgress + string.trimmingCharacters(in: CharacterSet.newlines)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        print("Parser failure error: ", parseError)
    }
}
