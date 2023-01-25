//
//  PlaceTableViewSearchDelegate.swift
//  favoritePlaces_floreceann_C0851646
//
//  Created by Ann Robles on 1/24/23.
//

import UIKit

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.contains(" ") {
            filteredPlaces = places
        } else if searchText.isEmpty {
            filteredPlaces = places
        } else {
            filteredPlaces = places?.filter { place in
                return place.name!.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.isUserInteractionEnabled = true

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()

        self.view.addSubview(activityIndicator)

        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)

        activityIndicator.stopAnimating()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.showsCancelButton = false

        filteredPlaces = places
        tableView.reloadData()
    }
}
