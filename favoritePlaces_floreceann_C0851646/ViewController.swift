//
//  ViewController.swift
//  favoritePlaces_floreceann_C0851646
//
//  Created by Ann Robles on 1/24/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var places:[Place]?
    var filteredPlaces:[Place]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetch()
    }
    
    @IBAction func filterButton(_ sender: UIBarButtonItem) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredPlaces?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let place = self.filteredPlaces?[indexPath.row] {
            cell.textLabel?.text = "\(place.name ?? "")"
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completionHandler) in
            
            if let placeToRemove = self.filteredPlaces?[indexPath.row] {
                self.delete(place: placeToRemove)
            }
            
            self.fetch()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.filteredPlaces?[indexPath.row]
        
        if let favoritePlaceViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddFavoritePlaceViewController") as? AddFavoritePlaceViewController {
            favoritePlaceViewController.myFavoritePlace = place
            self.navigationController?.pushViewController(favoritePlaceViewController, animated: true)
        }
    }
}

extension ViewController: AddFavoritePlaceViewControllerDelegate {
    func reloadTableview() {
        fetch()
        self.tableView.reloadData()
    }

}
