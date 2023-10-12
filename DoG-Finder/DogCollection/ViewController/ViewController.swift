//
//  ViewController.swift
//  DoG-Finder
//
//  Created by Ghaffar on 10/12/23.
//

import UIKit
import Combine
import CoreData
//import ANActivityIndicator

class ViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var dogsCollectionView: UICollectionView!
    @IBOutlet weak var btnToggle: UIButton!
    
    //MARK: member properties
    var pageNumber = 50
    var isGridMode = true
    var viewModel =  DogsVM()
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
        
        viewModel.fetchAllDetail()
        // if there is no data in coredata get it from api
        if viewModel.dogsCoreData.count == 0 {
            viewModel.fetchDogImages(pageNum: pageNumber)
        } else {
            dogsCollectionView.reloadData()
        }
    }
    
    /// Receive Response to bind with View Model
     func bindViews() {
        let viewModel = viewModel
        viewModel.$isSuccess.receive(on: DispatchQueue.main).dropFirst().sink(receiveValue: { [unowned self] isSuccess in
            if isSuccess {
                viewModel.fetchAllDetail()
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
                 viewModel.fetchAllDetail()
                 dogsCollectionView.reloadData()
             } else {
                 let alert =  UIAlertController(title: "Error", message: "Some thing went wrong", preferredStyle: .alert)
                 let okAction = UIAlertAction(title: "OK", style: .default)
                 alert.addAction(okAction)
                 self.show(alert, sender: self)
             }
         }).store(in: &subscriptions)
    }


    
    func setCollectionViewLayout(_ isGridMode: Bool) {
        let layout = UICollectionViewFlowLayout()
        if isGridMode {
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.itemSize = CGSize(width: (dogsCollectionView.frame.width - 30) / 2, height: 200)
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

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dogsCoreData.count // viewModel.dogImages.count ?? 0
      }

      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          
          if isGridMode {
              guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as? GridCell
                  else    {
                      fatalError()
              }
              let dogDetail = viewModel.dogsCoreData[indexPath.row]
              guard let imageURL = dogDetail.dogImageURL else { fatalError() }
              cell.lblBreed.text = dogDetail.breedName
              cell.btnFavourite.setImage(UIImage(systemName: dogDetail.isFavourite! ? "heart.fill" : "heart"), for: .normal)
              cell.configureCell(with: imageURL)
              cell.btnFavourite.tag = indexPath.item
              cell.delegate =  self
              return  cell

          } else {
              guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as? ListViewCell
                  else {
                      fatalError()
              }
              
              let dogDetail = viewModel.dogsCoreData[indexPath.row]
              guard let imageURL = dogDetail.dogImageURL else { fatalError() }
              cell.lblBreed.text = dogDetail.breedName
              cell.btnFavourite.setImage(UIImage(systemName: dogDetail.isFavourite! ? "heart.fill" : "heart"), for: .normal)
              cell.configureCell(with: imageURL)
              cell.btnFavourite.tag = indexPath.item
              cell.delegate =  self
              return  cell

          }
      }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scroll is ended")
        
        viewModel.fetchDogImages(pageNum: 20)
    }
}

extension ViewController : DogCellProtocol {
    
    func btnToggleFavouriteAction(_ sender: UIButton) {
        // implement favorite functionality
        
        viewModel.dogsCoreData[sender.tag].isFavourite = !viewModel.dogsCoreData[sender.tag].isFavourite!
        viewModel.markFavourite(dogInfo: viewModel.dogsCoreData[sender.tag])
    }
    
    
}

