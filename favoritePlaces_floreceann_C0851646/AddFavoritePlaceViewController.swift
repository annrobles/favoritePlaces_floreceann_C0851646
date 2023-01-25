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

class AddFavoritePlaceViewController: UIViewController {

    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var places: [Place] = [Place]()
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

}

extension AddFavoritePlaceViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        
        let place = Place(name: placemark.name, thoroughfare: placemark.thoroughfare, locality: placemark.locality, administrativeArea: placemark.administrativeArea,  postalCode: placemark.postalCode, country: placemark.country,  latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
        self.places.append(place)
        
        selectedPin = placemark
        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
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
