//
//  LocationManager.swift
//  CityPeople
//
//  Created by Kamal Kishor on 25/04/22.
//

import CoreLocation
import RxRelay

protocol LocationManagerProtocol {
    var permissionDenied: PublishRelay<Void> { get }
    var location: PublishRelay<CLLocation> { get }
    var locality: PublishRelay<String> { get }
}

class LocationManager: NSObject, LocationManagerProtocol {
    var locality = PublishRelay<String>()
    
    
    var permissionDenied = PublishRelay<Void>()
    var location = PublishRelay<CLLocation>()
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
    
    override init() {
        super.init()
        requestLocation()
    }
    
    private func requestLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            permissionDenied.accept(())
        case .notDetermined, .restricted:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locality.accept("-NA-")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location.accept(location)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if error != nil {
                self.locality.accept("-NA-")
            } else if let placemark = placemarks?.first {
                self.locality.accept(placemark.name ?? placemark.locality ?? placemark.administrativeArea ?? "")
            }
        }
    }
}
