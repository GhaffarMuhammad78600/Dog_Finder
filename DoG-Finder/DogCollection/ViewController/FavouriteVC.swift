//
//  FavouriteVC.swift
//  DoG-Finder
//
//  Created by Ghaffar on 10/16/23.
//

import UIKit
import Combine
import CoreData
import ANActivityIndicator

class FavouriteVC: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var dogsCollectionView: UICollectionView!
    @IBOutlet weak var btnToggle: UIButton!
    
    //MARK: member properties
    
    var isGridMode = true
    var viewModel =  FavouriteDogVM()
    private var subscriptions: Set<AnyCancellable> = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUI()
        bindViews()
        getData()
    }
    
    
    func configureUI() {
        dogsCollectionView.dataSource = self
        dogsCollectionView.delegate = self

        // Register the custom cell classes
        dogsCollectionView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "GridCell")
        dogsCollectionView.register(UINib(nibName: "ListViewCell", bundle: nil), forCellWithReuseIdentifier: "ListCell")
        
        // Set the initial layout
        setCollectionViewLayout(isGridMode)
    }
    func getData() {
        
        viewModel.fetchFavouriteList()
    }
    
    /// Receive Response to bind with View Model
     func bindViews() {
        let viewModel = viewModel
        viewModel.$isSuccess.receive(on: DispatchQueue.main).dropFirst().sink(receiveValue: { [unowned self] isSuccess in
            
            if isSuccess {
                viewModel.fetchFavouriteList()
                dogsCollectionView.reloadData()
            } else {
                let alert =  UIAlertController(title: "Error", message: "Some thing went wrong", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okAction)
                self.show(alert, sender: self)
            }
        }).store(in: &subscriptions)
         
         viewModel.$isMarkedFavourite.receive(on: DispatchQueue.main).dropFirst().sink(receiveValue: { [unowned self] isMarked in
             if isMarked {
                 viewModel.fetchFavouriteList()
                 dogsCollectionView.reloadData()
             } else {
                 let alert =  UIAlertController(title: "Error", message: "Some thing went wrong", preferredStyle: .alert)
                 let okAction = UIAlertAction(title: "OK", style: .default)
                 alert.addAction(okAction)
                 self.show(alert, sender: self)
             }
         }).store(in: &subscriptions)
         
         
         viewModel.$showSpinner.receive(on: DispatchQueue.main).sink(receiveValue: { showSpinner in
             showSpinner ? ANActivityIndicatorPresenter.shared.showIndicator() :            ANActivityIndicatorPresenter.shared.hideIndicator()
         }).store(in: &subscriptions)
    }
    
    func setCollectionViewLayout(_ isGridMode: Bool) {
        let layout = UICollectionViewFlowLayout()
        if isGridMode {
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 10
            layout.itemSize = CGSize(width: (dogsCollectionView.frame.width - 20) / 2, height: (dogsCollectionView.frame.width - 20) / 2)
        } else {
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.itemSize = CGSize(width: dogsCollectionView.frame.width - 20, height: 200)
        }
        dogsCollectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    @IBAction func btntoggleAction(_ sender: Any) {
        isGridMode.toggle()
        setCollectionViewLayout(isGridMode)
        dogsCollectionView.reloadData()
    }
}

extension FavouriteVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.arrFavouriteDogs.count // viewModel.dogImages.count ?? 0
      }

      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          
          if isGridMode {
              guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as? GridCell
                  else    {
                      fatalError()
              }
              let dogDetail = viewModel.arrFavouriteDogs[indexPath.row]
              guard let imageURL = dogDetail.dogImageURL else { fatalError() }
              cell.lblBreed.text = dogDetail.breedName
              cell.btnFavourite.setImage(UIImage(systemName: dogDetail.isFavourite! ? "heart.fill" : "heart"), for: .normal)
//              cell.configureCell(with: imageURL)
              cell.imgDog.loadImageWithCaching(fromURL: URL(string: imageURL)!, placeholder: UIImage(named: "PlaceHolder"))
              cell.btnFavourite.tag = indexPath.item
              cell.delegate =  self
              return  cell

          } else {
              guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as? ListViewCell
                  else {
                      fatalError()
              }
              
              let dogDetail = viewModel.arrFavouriteDogs[indexPath.row]
              guard let imageURL = dogDetail.dogImageURL else { fatalError() }
              cell.lblBreed.text = dogDetail.breedName
              cell.btnFavourite.setImage(UIImage(systemName: dogDetail.isFavourite! ? "heart.fill" : "heart"), for: .normal)
//              cell.configureCell(with: imageURL)
              cell.imgDog.loadImageWithCaching(fromURL: URL(string: imageURL)!, placeholder: UIImage(named: "PlaceHolder"))
              cell.btnFavourite.tag = indexPath.item
              cell.delegate =  self
              return  cell

          }
      }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scroll is ended")
        
//        viewModel.fetchDogImages(pageNum: 20)
    }
}

extension FavouriteVC : DogCellProtocol {
    
    func btnToggleFavouriteAction(_ sender: UIButton) {
        // implement favorite functionality
        
        viewModel.arrFavouriteDogs[sender.tag].isFavourite = !viewModel.arrFavouriteDogs[sender.tag].isFavourite!
        viewModel.markFavourite(dogInfo: viewModel.arrFavouriteDogs[sender.tag])
    }
    
    
}

