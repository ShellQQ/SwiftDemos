//
//  Ext+File.swift
//  MapTrack
//
//  Created by D02020015 on 2021/6/1.
//

import Foundation

func createFolder(directory: FileManager.SearchPathDirectory = .documentDirectory, folderName: String) -> URL {
    let paths = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true) // -> [String]
    let documentsDirectory = paths[0] //first
    let docURL = URL(fileURLWithPath: documentsDirectory) // scheme = "file://"
    let dataPath = docURL.appendingPathComponent(folderName)
    
    var ocb: ObjCBool = false //UnsafeMutablePointer<ObjCBool>?
    if FileManager.default.fileExists(atPath: dataPath.path, isDirectory: &ocb) == false {
        print(ocb.boolValue)
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    return dataPath
}

// Get data from document directory
func loadData(directory: FileManager.SearchPathDirectory = .documentDirectory, fileName: String) -> Data? {
    let filePath = createFolder(directory: directory, folderName: "Log").appendingPathComponent(fileName)
    do {
        let data = try Data(contentsOf: filePath)
        return data
    } catch {
        print(error.localizedDescription)
    }
    return nil
}
