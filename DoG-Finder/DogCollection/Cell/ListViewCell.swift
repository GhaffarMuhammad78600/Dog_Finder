//
//  ListViewCell.swift
//  DoG-Finder
//
//  Created by Ghaffar on 10/12/23.
//

import UIKit
import ImageKit
import NetworkHelper


class ListViewCell: UICollectionViewCell {
    
    // MARK: - outlets
    @IBOutlet weak var lblBreed: UILabel!
    @IBOutlet weak var imgDog: UIImageView!
    @IBOutlet weak var btnFavourite: UIButton!
    
    // MARK: - Member variables
    var delegate: DogCellProtocol?
    // MARK: - Member functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Adjust the radius as needed
        self.layer.cornerRadius = 10.0
          self.layer.masksToBounds = true

          // Set the border properties
          self.layer.borderWidth = 1.0 // Border width
          self.layer.borderColor = UIColor.gray.cgColor
    }
    
    // below function is use for  configuring image cell
    
    public func configureCell(with dogImage: String)  {
        imgDog.getImage(with: dogImage)   { [weak self] (result) in
            switch result   {
            case .failure(let appError): // failure case will be handle here
                print(appError)
                self?.imgDog.image = UIImage(named: "PlaceHolder")
                self?.lblBreed.text = "No bread found"
            case .success(let image): // success case will be handled here
                DispatchQueue.main.async {
                    self?.imgDog.image = image
                    let breadNames = dogImage.components(separatedBy: "/")
                    let brdName: String? = breadNames[breadNames.count - 2]
                    self?.lblBreed.text = brdName ??  "No bread found"
                }
            }
        }
    }
    
    // MARK: - IB Action
    
    // below code use to mark favourite and unfavourite an item
    @IBAction func btnToggleAction(_ sender: UIButton) {
        if  self.delegate != nil {
            delegate?.btnToggleFavouriteAction(sender)
        }
    }

}
