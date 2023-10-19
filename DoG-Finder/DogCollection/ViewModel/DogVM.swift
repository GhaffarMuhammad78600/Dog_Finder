//
//  DogVM.swift
//  DoG-Finder
//
//  Created by Ghaffar  on 10/12/23.
//
import Foundation
import Combine
import CoreData


final class DogsVM {
    
    // MARK: - Data members
//    @Published var apiError: AppError?
    @Published var showSpinner: Bool = true
    @Published var isSuccess: Bool = false
    @Published var isMarkedFavourite: Bool = false
    
    var pageNumber = 50
    var dogImages = [DogImage]()
    var dogsCoreData = [DogDetailCore]()
    var fetchedResultsController: NSFetchedResultsController<DogDetail>!
    
    init() {
        
    }
    
    // below functionality is for getting breeds list from api
     func fetchDogImages(pageNum: Int)  {
        let strPagNnumber = String(pageNumber + pageNum)
         pageNumber = pageNumber + pageNum
         showSpinner = true
        DogAPIClient.fetchDogs(pageNumber: strPagNnumber) { [weak self] (result) in
            guard let self = self else { return }
            showSpinner = false
            switch result  {
            case .failure(let appError):
                print(appError)
            case .success(let dogImages):
                self.dogImages = dogImages
                self.saveAllData()
                self.isSuccess = true
                print("all data saved yes it is")
            }
        }
    }
    
    func saveAllData() {
        for dogDetailUrl in dogImages {
            
            let breadNames = dogDetailUrl.components(separatedBy: "/")
            let brdName: String? = breadNames[breadNames.count - 2]
            
            let dogDetail = DogDetailCore(breedName: brdName, dogImageURL: dogDetailUrl, isFavourite: false)
            self.saveToCoreData(dogInfo: dogDetail)
        }
        print("all data saved")
        
    }
    func saveToCoreData(dogInfo: DogDetailCore) {
        let context = CoreDataStack.shared.viewContext
        let dogDetail = DogDetail(context: context)
        
        dogDetail.dogImageURL = dogInfo.dogImageURL ?? ""
        dogDetail.breadName = dogInfo.breedName  ??  "No bread found"
        dogDetail.isFavourite = dogInfo.isFavourite ?? false
        
        //save context
        do {
            try context.save()
            
        } catch {
            fatalError("could not save Dog entity: \(error.localizedDescription)")
        }
    }
    
    func fetchAllDetail() {
        showSpinner = true
        let context = CoreDataStack.shared.viewContext
        
        let fetchRequest: NSFetchRequest<DogDetail> = DogDetail.fetchRequest()
        dogsCoreData.removeAll()
        
        do {
            let dogs = try context.fetch(fetchRequest)
            for dog in dogs {
                dogsCoreData.append(DogDetailCore(breedName: dog.breadName, dogImageURL: dog.dogImageURL, isFavourite: dog.isFavourite) )
            }
            showSpinner = false
            isSuccess = true
        } catch {
            showSpinner = false
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
        showSpinner = true
        let context = CoreDataStack.shared.viewContext

        if let dogDetail = fetchDogDetailWith(imageURL: dogInfo.dogImageURL!) {
            dogDetail.isFavourite = dogInfo.isFavourite!  // Mark as favorite
            
            do {
                try context.save()
                isMarkedFavourite = true
            } catch {
                print("Error updating data in Core Data: \(error)")
            }
            
        }
        showSpinner = true
    }
}

