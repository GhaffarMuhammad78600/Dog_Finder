//
//  DogBreed.swift
//  DoG-Finder
//
//  Created by Ghaffar on 10/12/23.
//

import Foundation

typealias DogImage = String

struct  RandomDogInfo: Decodable {
    let message: [DogImage]
}

struct DogDetailCore {
    var breedName: String?
    var dogImageURL: String?
    var isFavourite: Bool?
}
