//
//  File.swift
//  ZMachine
//

import Foundation

func get_file(filename: String) -> CharString {
    let docsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true).first!
    let path = "\(docsPath)/\(filename)"
    
    if let data = NSData(contentsOfFile: path) {
        let count = data.length / sizeof(UInt32)
        var longArray = [UInt32](count: count, repeatedValue: 0)
        data.getBytes(&longArray, length: count * sizeof(UInt32))
        
        var array = [Int]()
        for long in longArray {
            array.append(Int(long >> 0 & UInt32(0xff)))
            array.append(Int(long >> 8 & UInt32(0xff)))
            array.append(Int(long >> 16 & UInt32(0xff)))
            array.append(Int(long >> 24 & UInt32(0xff)))
        }
        
        return array
    }
    fatalError("Could not load file '\(path)'")
}

