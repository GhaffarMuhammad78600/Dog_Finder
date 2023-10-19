//
//  DoG_FinderTests.swift
//  DoG-FinderTests
//
//  Created by Ghaffar on 10/12/23.
//

import XCTest


import XCTest
import CoreData
@testable import DoG_Finder

final class DoG_FinderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

class FavoriteFunctionalityTests: XCTestCase {
    
    var viewModel: DogsVM!
    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        // Initialize the ViewModel and create an in-memory Core Data stack for testing
        viewModel = DogsVM()
        let container = NSPersistentContainer(name: "YourAppName")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        managedObjectContext = container.viewContext
        viewModel.saveToCoreData(dogInfo: DogDetailCore(breedName: "TestBreed", dogImageURL: "testURL", isFavourite: false))
    }

    override func tearDown() {
        // Clean up after the test
        viewModel = nil
        super.tearDown()
    }

    func testFavoriteFunctionality() {
        // Check if the dog is not initially marked as favorite
        let initialDog = viewModel.dogsCoreData.first
        XCTAssertNotNil(initialDog)
        XCTAssertFalse((initialDog!.isFavourite != nil))

        // Mark the dog as favorite and save
        viewModel.markFavourite(dogInfo: initialDog!)
        XCTAssertTrue(viewModel.isMarkedFavourite)

        // Fetch the dog again from Core Data
        let favoriteDog = viewModel.fetchDogDetailWith(imageURL: "testURL")
        XCTAssertNotNil(favoriteDog)
        XCTAssertTrue(favoriteDog!.isFavourite)
    }
}
