//
//  ViewController.swift
//  CollectionViewJSON
//
//  Created by Gabriela Jimenez on 06/12/17.
//  Copyright © 2018 Gabriela Jimenez. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

struct Peregrino: Decodable {
    let localized_name: String
    let img: String
}

class ViewController: UIViewController, UICollectionViewDataSource {
    
    var peregrinos = [Peregrino]()

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self

        let url = URL(string: "http://peregrinacion-es.com/app_getnewimages.php")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error == nil {
                
                do {
                    self.peregrinos = try JSONDecoder().decode([Peregrino].self, from: data!)
                }catch {
                    print("No esta funcionando")
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            
        }.resume()
        
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peregrinos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCollectionViewCell
        
        cell.nameLbl.text = peregrinos[indexPath.row].localized_name.capitalized
        
        let defaultLink = "http://peregrinacion-es.com/app_images/"
        let completeLink = defaultLink + peregrinos[indexPath.row].img
        
        cell.imageView.downloadedFrom(link: completeLink)
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = cell.imageView.frame.height / 2
        cell.imageView.contentMode = .scaleAspectFill
        
        return cell
    }

}














