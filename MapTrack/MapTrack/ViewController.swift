//
//  ViewController.swift
//  MapTrack
//
//  Created by D02020015 on 2021/2/17.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    
    
    private let locationManager = CLLocationManager()
    private var seconds = 0
    private var timer: Timer?
    //private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var distance: Double = 0.0
    private var locationList: [CLLocation] = []
    
    private var locationStatus = "..."
    private var isRecord: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = createFolder(folderName: "Log")
        print("folder url \(url)")
        //loadLocalDistanceDic(p: &LocationManager.distanceDic)
        
        mapView.delegate = self
        //requestLocationAuth()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func recordTap(_ sender: UIButton) {
        if isRecord {
            stopRecord()
        }
        else {
            startRecord()
        }
    }
    
    func startRecord() {
        isRecord = true
        
        startButton.setTitle("停止", for: .normal)
        startButton.backgroundColor = .red
        
        seconds = 0
        //distance = Measurement(value: 0, unit: UnitLength.meters)
        distance = 0
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
    }
    
    func stopRecord() {
        isRecord = false
        
        startButton.setTitle("開始", for: .normal)
        startButton.backgroundColor = .green
        
        locationManager.stopUpdatingLocation()
    }
    
    func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest     // 精准度
        locationManager.startUpdatingLocation()
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    func updateDisplay() {
        //let formateedDistance = FormatDisplay.distance(distance)
        let distanceKM = NSString(format: "%.3f", (distance / 1000))
        //distanceLabel.text = "\(distanceKM) KM"
        distanceLabel.text = "\(distanceKM) KM"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                // 計算距離
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + delta
                //distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                //print("距離計算 \(delta)  \(Measurement(value: delta, unit: UnitLength.meters))")
                
                // 在地圖上畫路徑
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
                
                let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(region, animated: true)
            }
            locationList.append(newLocation)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        
        return renderer
    }
    
    
//    func requestLocationAuth() {
//
//        locationManager.requestAlwaysAuthorization()
//        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
//        switch CLLocationManager.authorizationStatus() {
//        case .authorizedAlways:
//            locationStatus = "authorized always"
//            checkLocationAccuracyAllowed()
//        case .authorizedWhenInUse:
//            locationStatus = "authorized when in use"
//            checkLocationAccuracyAllowed()
//        case .notDetermined:
//            locationStatus = "not determined"
//        case .restricted:
//            locationStatus = "restricted"
//        case .denied:
//            locationStatus = "denied"
//        default:
//            locationStatus = "other"
//        }
//    }
//
//    func checkLocationAccuracyAllowed() {
//        switch locationManager.accuracyAuthorization {
//        case .reducedAccuracy:
//            locationStatus = "approximate location"
//        case .fullAccuracy:
//            locationStatus = "accurate location"
//        default:
//            locationStatus = "unknown type"
//        }
//        locationManager.startUpdatingLocation()
//    }
    
    
    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        let status = manager.authorizationStatus
//        let accuracyStatus = manager.accuracyAuthorization
//
//        if(status == .authorizedWhenInUse || status == .authorizedAlways){
//
//            if accuracyStatus == CLAccuracyAuthorization.reducedAccuracy{
//                locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "wantAccurateLocation", completion: { [self]
//                    error in
//
//                    if locationManager.accuracyAuthorization == .fullAccuracy{
//                        locationStatus = "Full Accuracy Location Access Granted Temporarily"
//                    }
//                    else{
//                        locationStatus = "Approx Location As User Denied Accurate Location Access"
//                    }
//                    locationManager.startUpdatingLocation()
//                })
//            }
//        }
//        else{
//            requestLocationAuth()
//        }
//    }

}



struct FormatDisplay {
  static func distance(_ distance: Double) -> String {
    let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
    return FormatDisplay.distance(distanceMeasurement)
  }
  
  static func distance(_ distance: Measurement<UnitLength>) -> String {
    let formatter = MeasurementFormatter()
    return formatter.string(from: distance)
  }
  
  static func time(_ seconds: Int) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: TimeInterval(seconds))!
  }
  
  static func pace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> String {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = [.providedUnit] // 1
    let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
    let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
    return formatter.string(from: speed.converted(to: outputUnit))
  }
  
  static func date(_ timestamp: Date?) -> String {
    guard let timestamp = timestamp as Date? else { return "" }
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: timestamp)
  }
}

