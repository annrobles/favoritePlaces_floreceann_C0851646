//
//  AddFavoritePlaceViewController.swift
//  favoritePlaces_floreceann_C0851646
//
//  Created by Ann Robles on 1/24/23.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class AddFavoritePlaceViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D!
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var myFavoritePlace: Place?
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        map.isZoomEnabled = false
        map.showsUserLocation = true
        map.delegate = self
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)

        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as? any UISearchResultsUpdating
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = map
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.searchController = resultSearchController
        
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        let touchpoint = sender.location(in: map)
        let coordinate = map.convert(touchpoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        let marker: String
        map.removeAnnotations(map.annotations)
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: {(placemarks, error) in
            
            if error != nil {
                print(error!)
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        
                        if placeMark.locality != nil {
                            self.myFavoritePlace = Place(name: placeMark.name, thoroughfare: placeMark.thoroughfare, locality: placeMark.locality, administrativeArea: placeMark.administrativeArea,  postalCode: placeMark.postalCode, country: placeMark.country,  latitude: coordinate.latitude, longitude: coordinate.longitude)

                            annotation.title = placeMark.name
                            annotation.coordinate = coordinate
                            
                            if let city = placeMark.locality,
                            let state = placeMark.administrativeArea,
                            let postalcode = placeMark.postalCode {
                                annotation.subtitle = "\(city) \(state) \(postalcode)"
                            }
                            
                            self.map.addAnnotation(annotation)
                        }
                    }
                }
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        print(userLocation)
        displayLocation(latitude: latitude, longitude: longitude)
    }
    
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees) {
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees =  0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: true)
    }
}

extension AddFavoritePlaceViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        
        self.myFavoritePlace = Place(name: placemark.name, thoroughfare: placemark.thoroughfare, locality: placemark.locality, administrativeArea: placemark.administrativeArea,  postalCode: placemark.postalCode, country: placemark.country,  latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
        
        selectedPin = placemark
        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.title = placemark.name
        annotation.coordinate = placemark.coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        if let city = placemark.locality,
        let state = placemark.administrativeArea,
        let postalcode = placemark.postalCode {
            annotation.subtitle = "\(city) \(state) \(postalcode)"
        }
        map.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        map.setRegion(region, animated: true)
    }
}

extension AddFavoritePlaceViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {
            return nil
        }

        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        //annotationView.detailCalloutAccessoryView = label

        //label.widthAnchor.constraint(lessThanOrEqualToConstant: label.frame.width).isActive = true
        //label.heightAnchor.constraint(lessThanOrEqualToConstant: 90.0).isActive = true

        return annotationView
    }
}
