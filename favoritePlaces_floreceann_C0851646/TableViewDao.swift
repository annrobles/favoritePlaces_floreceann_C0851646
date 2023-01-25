//
//  TableViewDao.swift
//  favoritePlaces_floreceann_C0851646
//
//  Created by Ann Robles on 1/24/23.
//

import Foundation
import CoreData

extension ViewController {

    func delete(place: Place) {        
        try context.delete(place)
        
        do {
            try self.context.save()
        } catch  {
            print("Error deleting place \(error.localizedDescription)")
        }
    }
    
    func fetch() {
        do {
            let request = Place.fetchRequest() as NSFetchRequest<Place>
            
//            if searchText.text != "" {
//                let predicate = NSPredicate(format: "name CONTAINS %@", searchText.text!)
//                request.predicate = predicate
//            }
            
            self.places = try context.fetch(request)
        
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            
        }
    }
}
