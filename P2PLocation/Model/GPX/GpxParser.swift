//
//  GpxParser.swift
//  P2PLocation
//
//  Created by MyCom on 5/18/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol GpxParsing: NSObjectProtocol {
    func parser(_ parser: GpxParser, didCompleteParsing locations: Queue<CLLocation>)
}

class GpxParser: NSObject, XMLParserDelegate {
    private var locations: Queue<CLLocation>
    weak var delegate: GpxParsing?
    private var parser: XMLParser?
    
    init(forResource file: String, ofType typeName: String) {
        self.locations = Queue<CLLocation>()
        super.init()
        
        if let filepath = Bundle.main.path(forResource: file, ofType: typeName) {
            do {
                let contents = try String(contentsOfFile: filepath)
                let data = contents.data(using: .utf8)
                parser = XMLParser.init(data: data!)
                parser?.delegate = self
                print(contents)
            } catch {
                // contents could not be loaded
                print("+++++++++++++++++++++++++++   Contents could not be loaded")
            }
        } else {
            // example.txt not found!
            print("------------------------------     \(file).\(typeName) not found!")
        }
    }
    
    func parse() {
        self.parser?.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "wpt":
            if let latString =  attributeDict["lat"],
                let lat = Double.init(latString),
                let lonString = attributeDict["lon"],
                let lon = Double.init(lonString) {
                locations.enqueue(CLLocation(latitude: lat, longitude: lon))
            }
        default: break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        delegate?.parser(self, didCompleteParsing: locations)
    }
}
