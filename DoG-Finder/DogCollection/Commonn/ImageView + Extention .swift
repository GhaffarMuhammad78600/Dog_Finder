//
//  ImageView + Extention .swift
//  DoG-Finder
//
//  Created by Ahmad Qasim on 10/16/23.
//
import UIKit


class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()

    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}


extension UIImageView {
    func loadImageWithCaching(fromURL url: URL, placeholder: UIImage? = nil) {
        if let cachedImage = ImageCache.shared.image(forKey: url.absoluteString) {
            self.image = cachedImage
        } else {
            self.image = placeholder

            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data, error == nil, let image = UIImage(data: data) else {
                    return
                }

                ImageCache.shared.set(image, forKey: url.absoluteString)

                DispatchQueue.main.async {
                    self?.image = image
                }
            }.resume()
        }
    }
}

