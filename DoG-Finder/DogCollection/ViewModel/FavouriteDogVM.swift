//
//  FavouriteDogVM.swift
//  DoG-Finder
//
//  Created by Ghaffar on 10/16/23.
//


import Foundation
import Combine
import CoreData

final class FavouriteDogVM {
    
    // MARK: - Data members
//    @Published var apiError: AppError?
    @Published var showSpinner: Bool = true
    @Published var isSuccess: Bool = false
    @Published var isMarkedFavourite: Bool = false
    
    var dogImages = [DogImage]()
    var arrFavouriteDogs = [DogDetailCore]()
    var fetchedResultsController: NSFetchedResultsController<DogDetail>!
    
    init() {
        
    }
    
    func fetchFavouriteList() {
        
        let context = CoreDataStack.shared.viewContext
        
        arrFavouriteDogs.removeAll()
        do {
            let fetchRequest: NSFetchRequest<DogDetail> = DogDetail.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isFavourite == true")

            let dogs = try context.fetch(fetchRequest)

            for dog in dogs {
                arrFavouriteDogs.append(DogDetailCore(breedName: dog.breadName, dogImageURL: dog.dogImageURL, isFavourite: dog.isFavourite))
            }

            isSuccess = true
        } catch {
            print("Error fetching data: \(error)")
        }

    }
    
    func fetchDogDetailWith(imageURL: String) -> DogDetail? {
        let context = CoreDataStack.shared.viewContext
        
        let fetchRequest: NSFetchRequest<DogDetail> = DogDetail.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dogImageURL == %@", imageURL as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching data from Core Data: \(error)")
            return nil
        }
    }
    
    func markFavourite(dogInfo: DogDetailCore ) {
        
        let context = CoreDataStack.shared.viewContext
        showSpinner = true
        if let dogDetail = fetchDogDetailWith(imageURL: dogInfo.dogImageURL!) {
            dogDetail.isFavourite = dogInfo.isFavourite!  // Mark as favorite
            
            do {
                try context.save()
                isMarkedFavourite = true
            } catch {
                print("Error updating data in Core Data: \(error)")
            }
        }
    }
}

