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

protocol AddFavoritePlaceViewControllerDelegate {
    func reloadTableview()
}

class AddFavoritePlaceViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D!
    var delegate: AddFavoritePlaceViewControllerDelegate?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
                            annotation.title = placeMark.name
                            annotation.coordinate = coordinate
                            
                            if let city = placeMark.locality,
                            let state = placeMark.administrativeArea,
                            let postalcode = placeMark.postalCode {
                                annotation.subtitle = "\(city) \(state) \(postalcode)"
                            }
                            
                            self.map.addAnnotation(annotation)
                            
                            if self.myFavoritePlace == nil {
                                var newPlace = Place(context: self.context)
                                newPlace.name = placeMark.name
                                newPlace.thoroughfare = placeMark.thoroughfare
                                newPlace.locality = placeMark.locality
                                newPlace.administrativeArea = placeMark.administrativeArea
                                newPlace.postalCode = placeMark.postalCode
                                newPlace.latitude = coordinate.latitude
                                newPlace.longitude = coordinate.longitude
                            }
                            else {
                                self.myFavoritePlace?.name = placeMark.name
                                self.myFavoritePlace?.thoroughfare = placeMark.thoroughfare
                                self.myFavoritePlace?.locality = placeMark.locality
                                self.myFavoritePlace?.administrativeArea = placeMark.administrativeArea
                                self.myFavoritePlace?.postalCode = placeMark.postalCode
                                self.myFavoritePlace?.latitude = coordinate.latitude
                                self.myFavoritePlace?.longitude = coordinate.longitude
                            }
                            self.savePlace()
                            self.delegate?.reloadTableview()
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
                         longitude: CLLocationDegrees)
    {
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees =  0.05
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location: CLLocationCoordinate2D!
        
        if myFavoritePlace != nil {
            addAnnotationForFavoritePlace(place: myFavoritePlace!)
            location = CLLocationCoordinate2D(latitude: myFavoritePlace!.latitude, longitude: myFavoritePlace!.longitude)
        }
        else {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    func addAnnotationForFavoritePlace(place: Place) {
        let annotation = MKPointAnnotation()
        annotation.title = place.name
        annotation.coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        
        if let city = place.locality,
        let state = place.administrativeArea,
        let postalcode = place.postalCode {
            annotation.subtitle = "\(city) \(state) \(postalcode)"
        }
        
        map.addAnnotation(annotation)
    }
}

extension AddFavoritePlaceViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        
        var newPlace = Place(context: self.context)
        newPlace.name = placemark.name
        newPlace.thoroughfare = placemark.thoroughfare
        newPlace.locality = placemark.locality
        newPlace.administrativeArea = placemark.administrativeArea
        newPlace.postalCode = placemark.postalCode
        newPlace.latitude = placemark.coordinate.latitude
        newPlace.longitude = placemark.coordinate.latitude
        self.savePlace()
        self.delegate?.reloadTableview()
        
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
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        annotationView.animatesDrop = true
        annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        annotationView.isDraggable = true
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            print("ending")
            view.dragState = .none
        default: break
        }
    }
}
