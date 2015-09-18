//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Chris Archibald on 9/12/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageActivity: UIActivityIndicatorView!
    
    func setOurImage(image:UIImage){
        
        self.imageActivity.stopAnimating()
        self.imageActivity.hidden = true
        self.image.image = image
        
    }
    
    func removeImage(){
        
        self.image.image = nil
        self.imageActivity.hidden = false
        self.imageActivity.startAnimating()
        
    }
}
