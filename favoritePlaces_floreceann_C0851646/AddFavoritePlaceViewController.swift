//
//  AddFavoritePlaceViewController.swift
//  favoritePlaces_floreceann_C0851646
//
//  Created by Ann Robles on 1/24/23.
//

import UIKit

class AddFavoritePlaceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension AddFavoritePlaceViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        var marker: String?
        
//        cityCnt = cities.count
//
//        if cityCnt == 0 {
//            marker = "A"
//        }
//        else if cityCnt == 1 {
//            marker = "B"
//        }
//        else {
//            marker = "C"
//        }
        
        let distance: Double = self.getDistance(from: self.userLocation, to:  placemark.coordinate)
        let place = City(title: marker,
                         subtitle: placemark.locality!,
                         coordinate: placemark.coordinate)
        
        self.citiesInAnnotation.append(placemark.locality!)
        self.cities.append(place)
        self.map.addAnnotation(place)
        self.distancesBetweenCityUser.append("\(String.init(format: "%2.f",  round(distance * 0.001)))km")
        
        if self.cities.count == 3 {
            self.addPolyline()
            self.addPolygon()
        }
    }
}
