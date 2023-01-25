//
//  AddFavoritePlaceDao.swift
//  favoritePlaces_floreceann_C0851646
//
//  Created by Ann Robles on 1/24/23.
//

extension AddFavoritePlaceViewController {

    func savePlace() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error.localizedDescription)")
        }
    }
}
