//
//  LocationManager.swift
//  MapTrack
//
//  Created by D02020015 on 2021/2/17.
//

import CoreLocation

// 距離紀錄存檔
struct Distance_Info: Codable {
    var start_hour: Date                        // 開始時間
    var distance: Double                        // 總距離
    var locationList: [Distance_Location]       // 座標紀錄
    var currentLocation: Distance_Location      // 當下的使用者座標（開起與結束紀錄時需上傳使用者當前座標，其餘不用）
    var needUpload: Bool                        // 是否已上傳
    
    init() {
        //start_hour = Date().setMinuteSecond(min:59, sec:59)!
        start_hour = Date()
        distance = 0
        locationList = []
        currentLocation = Distance_Location()
        needUpload = true
    }
}

struct Distance_Location: Codable {
    var lat: Double
    var lng: Double
    
    init(lat: Double = 0, lng: Double = 0) {
        self.lat = lat
        self.lng = lng
    }
}

class LocationManager {
    static let shared = CLLocationManager()
    static var distanceDic: [String: [Distance_Info]] = [:]
    
    private init() {
        
    }
}

// 儲存 distance 資料
func loadLocalDistanceDic(p: UnsafeMutablePointer<[String: [Distance_Info]]>) {
    let fileName = "distanceDic.txt"

    if let data = loadData(directory: .documentDirectory, fileName: fileName) {
        print("載入行程紀錄")
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .deferredToData
        p.pointee = try! decoder.decode(([String: [Distance_Info]]).self, from: data)
        print(p.pointee as Any)
    }
}
